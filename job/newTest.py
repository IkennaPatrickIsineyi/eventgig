
from datetime import datetime
from gevent.pywsgi import WSGIServer
from flask import Flask, request
import psycopg2 as conn
from werkzeug.exceptions import abort
from werkzeug.utils import secure_filename
import os
import json

from flask_sock import Sock
import simple_websocket

#from flask_sockets import Sockets
from scripts import event_planner
#import eventlet

# from flask_socketio import SocketIO, join_room, leave_room, emit, send


# import socketio
# create socket server


application = Flask(__name__, static_url_path='/static')
path = os.getcwd()
application.config['UPLOAD_FOLDER'] = os.path.join(path, 'mysite/static')
# socket = SocketIO(application, cors_allowed_origins="*")
socket = Sock(application)


userSockets = {}
""" userHost = {'host': [simple_websocket.ws.Server]}
if userHost.__contains__('host'):
    f = userHost['host']
    for d in f:
        d.close() """
# map of list of sockets {key:[str,str],key:[str,str]}
# the keys are the usernames.
# the values of each key are the sockets associated with the username


def multicastMsg(user, msg):
    # send message to each of the clients belonging to the user
    # userSockets is a dict of Lists. Each dict is a List
    for userSock in userSockets[user]:
        userSock.send(json.dumps({'status': 'connected'}))


def connectDBServ():
    DATABASE_URL = os.environ['DATABASE_URL']
    # PORT = os.environ['PORT']
    db = conn.connect(DATABASE_URL)

    cursor = db.cursor()
    # allTokens, deadTokens=refreshTokenRecord.refresh_tokens_record(db, cursor)
    return db, cursor


def saveSocket(user: str, sock: simple_websocket.ws.Server):
    if not userSockets.__contains__(user):
        print('creating username key...')
        userSockets[user] = set([sock])
    else:
        print('username key exists.')
        if not userSockets[user].__contains__(sock):
            userSockets[user].add(sock)
            print('socket added...')
        else:
            print('socket already exists')


@socket.route('/ws')
def wsd(socet: simple_websocket.ws.Server):
    #socet.ping_interval = 25
    print('ws called')
    #print('threadOut: ', socet.thread.native_id)
    # print(socet.connected)
    print("accepted")
    # x = socet.receive()
    username = ""
    code = 0
    # print(socet.environ)
    shown = False
    """ host = socet.environ['HTTP_ORIGIN']
    if userHost.__contains__(host):
        for client in userHost[host]:
            client.close()
    else:
        userHost[host].append(socet) """

    socet.send(json.dumps({'intro': 'connected'}))
    t = datetime.now()
    reminded = False
    while True:
        dat = socet.receive(timeout=0)
        if dat != None:
            print('new msg')
            print('from ', socet)

            """ if shown == False:
                print('threadIn: ', socet.thread.native_id)
                shown = True """
            payld = json.loads(dat)
            print(payld)
            t = datetime.now()
            reminded = False
            # reset timer whenever new message is received from this socket

            if payld['intro'] == 'alive':
                print("alive called...")
                print(username, socet)
                if payld['username'] == "" or payld['username'] == None:
                    print('Client dead. Closing... ', socet)
                    for wsc in userSockets:
                        if userSockets[wsc].__contains__(socet):
                            userSockets[wsc].remove(socet)
                            if len(userSockets[wsc]) == 0:
                                userSockets.pop(wsc)
                    print('closed...', socet)
                    return
                result = event_planner.updateLastSeenF(username)
            elif payld['intro'] == 'login':
                print("login called...")
                result = event_planner.loginProcessor(
                    payld['username'], payld['password'])
                socet.send(json.dumps({'intro': 'login', 'result': result}))
            elif payld['intro'] == 'savesession':
                print("savesession called...")
                result, valid = event_planner.saveSessionF(
                    payld['username'], payld['password'], payld['deviceid'], payld['deviceToken'])
                if(valid == "valid"):
                    username = payld['username']
                    if not userSockets.__contains__(username):
                        print('creating username key...')
                        userSockets[username] = set([socet])
                    else:
                        print('username key exists.')
                        userSockets[username].add(socet)
                socet.send(json.dumps(
                    {'intro': 'savesession', 'result': result}))

            elif payld['intro'] == 'passwordotp':
                print("passwordotp called...")
                result = event_planner.passwordotpF(
                    payld['username'], payld['subject'])
                socet.send(json.dumps(
                    {'intro': 'passwordotp', 'result': result}))
            elif payld['intro'] == 'resetpassword':
                result = event_planner.resetpasswordF(
                    payld['username'], payld['otp'], payld['password'])
                socet.send(json.dumps(
                    {'intro': 'resetpassword', 'result': result}))
            elif payld['intro'] == 'getunclicked':
                result = event_planner.getUnclickedF(
                    payld['username'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'getunclicked', 'result': result}))
            elif payld['intro'] == 'detailproc':
                result = event_planner.detailprocF(
                    payld['username'], payld['trnxid'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'detailproc', 'result': result}))
            elif payld['intro'] == 'getsettings':
                result = event_planner.getsettingsF(
                    payld['username'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'getsettings', 'result': result}))
            elif payld['intro'] == 'chathistory':
                result = event_planner.chathistoryF(
                    payld['username'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'chathistory', 'result': result}))
            elif payld['intro'] == 'genOtp':
                result = event_planner.genOtpF(
                    payld['username'], payld['subject'], payld['sessionid'])
                if result['status'] == 'sent':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps({'intro': 'genOtp', 'result': result}))
            elif payld['intro'] == 'verifyOtp':
                result = event_planner.verifyotpF(
                    payld['otp'], payld['username'], payld['sessionid'])
                if result['status'] == 'verified':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'verifyOtp', 'result': result}))
            elif payld['intro'] == 'updateLastSeen':
                result = event_planner.updateLastSeenF(
                    payld['username'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'updateLastSeen', 'result': result}))
            elif payld['intro'] == 'homeproc':
                result, valid = event_planner.homeprocF(
                    payld['username'], payld['sessionid'])
                if valid == "valid":
                    username = payld['username']
                    if not userSockets.__contains__(username):
                        print('creating username key...')
                        userSockets[username] = set([socet])
                    else:
                        print('username key exists.')
                        if not userSockets[username].__contains__(socet):
                            userSockets[username].add(socet)
                socet.send(json.dumps({'intro': 'homeproc', 'result': result}))
            elif payld['intro'] == 'regproc':
                print('regproc called')
                result, valid = event_planner.regprocF(
                    payld['username'], payld['password'], payld['email'], payld['gender'])
                if valid == 'error':
                    print("error caught...")
                    print(result['error'])
                    socet.send(json.dumps(
                        {'intro': 'regprocError', 'result': result}))
                else:
                    print('success')
                    if valid == "yes":
                        username = payld['username']
                        if not userSockets.__contains__(username):
                            print('creating username key...')
                            userSockets[username] = set([socet])
                        else:
                            print('username key exists.')
                            userSockets[username].add(socet)
                    socet.send(json.dumps(
                        {'intro': 'regproc', 'result': result}))
            elif payld['intro'] == 'logout':
                result = event_planner.logoutF(
                    payld['username'], payld['sessionid'])
                print('cleaning up socket')
                if username != "":
                    if userSockets.__contains__(username):
                        if userSockets[username].__contains__(socet):
                            userSockets[username].remove(socet)
                            # remove username key from dict if it has no sockets
                            # ie if the list is empty
                            if len(userSockets[username]) == 0:
                                print('last member deleted')
                                userSockets.pop(username)
                socet.send(json.dumps(
                    {'intro': 'logout', 'result': result}))
                return
            elif payld['intro'] == 'ordproc':
                result = event_planner.ordprocF(
                    payld['username'], payld['sessionid'], payld['budget'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'ordproc', 'result': result}))
            elif payld['intro'] == 'plannerdetails':
                result = event_planner.plannerdetailsF(
                    payld['username'], payld['planner'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'plannerdetails', 'result': result}))
            elif payld['intro'] == 'hireproc':
                result = event_planner.hireprocF(payld['street'], payld['city'],
                                                 payld['state'], payld['country'], payld['date'],
                                                 payld['type'], payld['budget'], payld['note'],
                                                 payld['sessionid'], payld['username'],
                                                 payld['planner'], payld['fee'])
                if result['status'] == 'available':
                    if userSockets.__contains__(payld['planner']):
                        for wsc in userSockets[payld['planner']]:
                            wsc.send(json.dumps({'intro': 'newOrder'}))
                socet.send(json.dumps(
                    {'intro': 'hireproc', 'result': result}))
            elif payld['intro'] == 'savesettings':
                result = event_planner.savesettingsF(payld['email'], payld['phone'],
                                                     payld['profilePic'], payld['terms'], payld['username'],
                                                     payld['sessionid'], payld['planner'], payld['fee'])
                if result['status'] == 'available':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'savesettings', 'result': result}))
            elif payld['intro'] == 'getshowroom':
                result = event_planner.getshowroomF(
                    payld['username'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'getshowroom', 'result': result}))
            elif payld['intro'] == 'deletepic':
                result = event_planner.deletepicF(
                    payld['username'], payld['showroomid'], payld['sessionid'])
                if result['status'] == 'deleted':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'deletepic', 'result': result}))
            elif payld['intro'] == 'clickedNotification':
                result = event_planner.clickedNotificationF(
                    payld['username'], payld['sessionid'], payld['notifyid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'clickedNotification', 'result': result}))
            elif payld['intro'] == 'sendchat':
                result = event_planner.sendchatF(
                    payld['message'], payld['receiver'], payld['username'], payld['sessionid'])
                if result['status'] == 'sent':
                    saveSocket(payld['username'], socet)
                    if userSockets.__contains__(payld['receiver']):
                        i = 0
                        for rec in userSockets[payld['receiver']]:
                            """sender, receiver,time,date,message"""
                            """result=[time,date,sender,receiver,message,seen,chatid]"""
                            try:
                                print('sending multicast messgage ', i)
                                rec.send(json.dumps(
                                    {'intro': 'newChat', 'result': [result['time'],
                                                                    result['date'],  payld['username'],
                                                                    payld['receiver'],  payld['message'],
                                                                    result['seen'], result['chatid']]}))
                                print('sent msg ', i)
                                i += 1
                            except:
                                print('error occured')
                                pass
                socet.send(json.dumps(
                    {'intro': 'sendchat', 'result': result}))
            elif payld['intro'] == 'getchats':
                result = event_planner.getchatsF(
                    payld['username'], payld['receiver'], payld['sessionid'], payld['nextchatid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'getchats', 'result': result}))
            elif payld['intro'] == 'deletechats':
                result = event_planner.deleteChatsF(
                    payld['username'], payld['sessionid'], payld['chatids'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'deletechats', 'result': result}))
            elif payld['intro'] == 'userdetails':
                result = event_planner.userdetailsF(
                    payld['username'], payld['user'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'userdetails', 'result': result}))
            elif payld['intro'] == 'finish':
                result = event_planner.finishF(
                    payld['username'], payld['trnxid'], payld['sessionid'], payld['rating'], payld['comment'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'finish', 'result': result}))
            elif payld['intro'] == 'accptjobproc':
                result = event_planner.acceptJobF(
                    payld['username'], payld['trnxid'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'accptjobproc', 'result': result}))
            elif payld['intro'] == 'rejjobproc':
                result = event_planner.rejjobprocF(
                    payld['username'], payld['sessionid'], payld['trnxid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'rejjobproc', 'result': result}))
            elif payld['intro'] == 'cancproc':
                result = event_planner.cancelJobF(
                    payld['username'], payld['trnxid'], payld['sessionid'])
                if result['status'] == 'valid':
                    saveSocket(payld['username'], socet)
                socet.send(json.dumps(
                    {'intro': 'cancproc', 'result': result}))
            elif payld['intro'] == 'getOnlineStatus':
                print('getOnlineStatus called')
                members = payld['users']
                online = []
                notOnline = []
                for member in members:
                    if userSockets.__contains__(member):
                        online.append(1)
                    else:
                        notOnline.append(member)
                        online.append(0)
                print(online)
                result = event_planner.getLastSeen(
                    payld['username'], members, payld['sessionid'])
                print(result)

                if result['status'] == 'valid':
                    result['users'] = members
                    result['onlineStatus'] = online
                    saveSocket(payld['username'], socet)
                    print(result)
                    socet.send(json.dumps(
                        {'intro': 'getOnlineStatus', 'result': result}))
                else:
                    result.__delitem__('last_seen')
                    socet.send(json.dumps(
                        {'intro': 'getOnlineStatus', 'result': result}))
            # print(payld)
            print(userSockets)
            print("received")
            t = datetime.now()
            # sleep(3)
            # socet.send(json.dumps({'intro': "message received"}))

        else:
            if (datetime.now()-t).total_seconds() >= 5 and reminded == False:
                print("checking if client is still alive...")
                socet.send(json.dumps({'intro': 'ping'}))
                t = datetime.now()
                reminded = True
            elif (datetime.now()-t).total_seconds() >= 2 and reminded == True:
                print('Client dead. Closing...')
                # remove socket from list of sockets associated with username
                if username != "":
                    if userSockets.__contains__(username):
                        if userSockets[username].__contains__(socet):
                            userSockets[username].remove(socet)
                            # remove username key from dict if it has no sockets
                            # ie if the list is empty
                            if len(userSockets[username]) == 0:
                                userSockets.pop(username)
                print(userSockets)
                print('Socket closed by server')
                return
            else:
                continue


def checkClient(sc: simple_websocket.ws.Server):
    sc.send(json.dumps({'status': 'ping'}))


@application.route('/img/<filen>', methods=['POST', 'GET'])
def imageFile(filen):
    return application.send_static_file(filename=filen)

@application.route('/uploadpic', methods=['POST', 'GET'])
def uploadpic():
    resp = event_planner.uploadpicF()
    return resp

@application.route('/changedp', methods=['POST', 'GET'])
def changedp():
    resp = event_planner.changeDPF()
    return resp


@ application.route('/', methods=['POST', 'GET'])
def index():
    return 'Welcome to EventGig'


if __name__ == '__main__':
    print('new Connection created...')
    PORT = os.environ['PORT']
    servr = WSGIServer(("", PORT), application=application)
    servr.serve_forever()

""" if __name__ == '__main__':
    # socket.run(application, host="127.0.0.1", port="3535", debug=True)

    application.run(debug=True) """
