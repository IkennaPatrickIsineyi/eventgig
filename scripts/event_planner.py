
from logging import debug, log
from flask import Flask, request
import json
import requests
from codecs import decode
import smtplib
import ssl
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import random
import psycopg2 as conn
from datetime import datetime
import hashlib
from flask.helpers import url_for
from flask.wrappers import Response
from werkzeug.exceptions import abort
from werkzeug.utils import secure_filename

#from pyfcm import FCMNotification

from . import loginproc
from .import accptjobproc
from .import cancproc
from .import changedp
from .import chathistory
from . import deletepic
from . import detailproc
from . import finish
from . import genOtp
from . import getchats
from . import getsettings
from . import getshowroom
from . import hireproc
from . import homeproc
from . import logout
from . import ordproc
from . import passwordotp
from . import plannerdetails
from . import regproc
from . import rejjobproc
from . import resetpassword
from . import savesettings
from . import sendchat
from . import deletechats
from . import getOnlineStatus
from . import updateLastSeen
from . import getMessageUpdate

from . import getupdate
from . import notifyseen

from . import uploadpic
from . import verifyotp

from . import notifyuser
from . import notifyusers
from . import notifyusersFBA
from . import saveSession
from . import userdetails

from . import getunseen
from . import getunclicked
from . import seenNotification
from . import clickedNotification

from . import refreshTokenRecord

app = Flask(__name__, static_url_path='/static')
path = os.getcwd()
app.config['UPLOAD_FOLDER'] = os.path.join(path, 'mysite/static')

x = datetime.now()
nowtime = x.strftime('%I')+':' + \
    x.strftime('%M')+' '+x.strftime('%p')
nowdate = x.strftime('%d')+'-' + \
    x.strftime('%b')+'-'+x.strftime('%Y')
time_created = nowdate+'  '+nowtime


def connectDBServ():
    DATABASE_URL = os.environ['DATABASE_URL']
    # PORT = os.environ['PORT']
    db = conn.connect(DATABASE_URL)

    cursor = db.cursor()
    #allTokens, deadTokens=refreshTokenRecord.refresh_tokens_record(db, cursor)
    return db, cursor

# get password and user classification of the user


def updateNotify(db, cursor, time, date, receiver, body, title, trnxid):
    if trnxid == None:
        strg = "insert into notifytb (time,date,receiver,body,seen,title) values ('{}','{}','{}','{}','{}','{}')".format(
            time, date, receiver, body, 0, title)
    else:
        strg = "insert into notifytb (time,date,receiver,body,seen,title, trnxid) values ('{}','{}','{}','{}','{}','{}','{}')".format(
            time, date, receiver, body, 0, title, trnxid)
    cursor.execute(strg)
    db.commit()


@app.route('/', methods=['POST', 'GET'])
def index():
    return 'Welcome to EventGig'


@app.route('/img/<filen>', methods=['POST', 'GET'])
def imageFile(filen):
    return app.send_static_file(filename=filen)


@app.route('/testmulti', methods=['POST', 'GET'])
def testMultiF():
    try:
        #username, trnxid, sessionid = accptjobproc.getName()
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')

        title = "New Login"
        """ email_result(username,personal[0][0],title) """

        body = """{}, a device just logged into your account""".format(
            username)
        result = notifyusersFBA.send_notif(db, cursor, username, title, body)

        state = {"status": result}

        feedback = Response(json.dumps(state))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/testmulti1', methods=['POST', 'GET'])
def testMulti1F():
    try:
        db, cursor = connectDBServ()
        allTokens, deadTokens = refreshTokenRecord.refresh_tokens_record(
            db, cursor)

        state = {"all": allTokens, "dead": deadTokens}

        feedback = Response(json.dumps(state))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/accptjobproc', methods=['POST', 'GET'])
def acceptJobF(username, trnxid, sessionid):
    try:
        #username, trnxid, sessionid = accptjobproc.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            trnxid = request.form['trnxid']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            trnxid = request.args.get('trnxid')
            sessionid = request.args.get('sessionid') """

        password_ = loginproc.get_password(cursor, username)

        trnxStatus, username1, client = accptjobproc.getStatus(
            db, cursor, int(trnxid), sessionid)

        if trnxStatus == 'pending' and username1 == username and username != client:
            accptjobproc.updt(db, cursor, int(trnxid),
                              time_created, username, client)
            title = "Order ACCEPTED"
            body = "{} accepted your order".format(username)
            """ updateNotify(db, cursor, nowtime, nowdate,
                         client, body, title, int(trnxid))
            """
            state = {"status": "valid"}

        elif trnxStatus != 'initial' or username1 != username or username == client:
            state = {"status": "Invalid"}

        feedback = state
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getupdate', methods=['POST', 'GET'])
def getUpdateF():
    try:
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')

        username1 = getupdate.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            notification = getupdate.retrivNotification(db, cursor, username)
            if len(notification) == 0:
                reply = {'status': 'valid', "empty": 'yes'}
            elif len(notification) > 0:
                reply = {'status': 'valid', "empty": 'no',
                         'notification': notification}
                getupdate.updateNotify(db, cursor, notification)

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getOnlineStatus', methods=['POST', 'GET'])
def getOnlineStatusF():
    try:
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
            users = json.loads(request.form['users'])
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')
            users = request.args.get('users')

        username1 = getOnlineStatus.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            onlineStatus, last_seen = getOnlineStatus.getOnlineStatus(
                db, cursor, users)
            reply = {'status': 'valid',
                     "onlineStatus": onlineStatus, "last_seen": last_seen}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getMessageUpdate', methods=['POST', 'GET'])
def getMessageUpdateF():
    try:
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
            sender = request.form['sender']
            chatid = request.form['chatid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')
            sender = request.args.get('sender')
            chatid = request.args.get('chatid')

        username1 = getMessageUpdate.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            chats = getMessageUpdate.retrivChats(
                db, cursor, username, sender, int(chatid))
            reply = {'status': 'valid', "chats": chats}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/updateLastSeen', methods=['POST', 'GET'])
def updateLastSeenF(username):
    try:
        db, cursor = connectDBServ()

        updateLastSeen.updateLastSeen(db, cursor, username)
        reply = {'status': 'valid'}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/deletechats', methods=['POST', 'GET'])
def deleteChatsF(username, sessionid, chatids):
    try:
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
            chatids = request.form['chatids']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')
            chatids = request.args.get('chatids') """

        username1 = deletechats.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            deletechats.deleteChats(db, cursor, chatids, username)
            reply = {'status': 'valid'}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getunseen', methods=['POST', 'GET'])
def getUnseenF():
    try:
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')

        username1 = getunseen.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            unseen = getunseen.retrivUnseen(db, cursor, username)
            reply = {'status': 'valid', 'unseen': unseen}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getunclicked', methods=['POST', 'GET'])
def getUnclickedF(username, sessionid):
    try:
        db, cursor = connectDBServ()

        username1 = getunclicked.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            unclicked = getunclicked.retrivNotifications(db, cursor, username)
            reply = {'status': 'valid', 'unclicked': unclicked}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/clickedNotification', methods=['POST', 'GET'])
def clickedNotificationF(username, sessionid, notifyid):
    try:
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
            notifyid = request.form['notifyid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')
            notifyid = request.args.get('notifyid') """

        username1 = clickedNotification.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            clickedNotification.clicked(db, cursor, int(notifyid))
            reply = {'status': 'valid'}
            print('clickedNotification done')

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/notifyseen', methods=['POST', 'GET'])
def notifyseenF():
    try:
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            notifyid = request.form['notifyid']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            notifyid = request.args.get('notifyid')
            sessionid = request.args.get('sessionid')

        username1 = notifyseen.auth(db, cursor, sessionid)

        if len(username1) == 0:
            reply = {"status": "hacker"}
        elif len(username1) > 0:
            if username1[0][0] == username:
                notifyseen.updateNotify(db, cursor, notifyid)
                reply = {"status": "valid"}

            elif username1[0][0] != username:
                reply = {"status": "hacker"}

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/cancproc', methods=['POST', 'GET'])
def cancelJobF(username, trnxid, sessionid):
    try:
        #username, trnxid, sessionid = cancproc.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            trnxid = request.form['trnxid']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            trnxid = request.args.get('trnxid')
            sessionid = request.args.get('sessionid') """

        trnxStatus, username1, client, email, victim = cancproc.getStatus(
            db, cursor, int(trnxid), sessionid)

        if trnxStatus == 'scheduled' and username1 == username:
            cancproc.updt(db, cursor, int(trnxid),
                          time_created, username, client)

            title = "Event Cancelled"
            body = "{} cancelled your upcoming event".format(username)

            """ updateNotify(db, cursor, nowtime, nowdate,
                         victim, body, title, int(trnxid)) """
            """ email_result(username,email,title,victim) """

            state = {"status": "valid"}

        elif trnxStatus != 'initial' or username1 != username:
            state = {"status": "Invalid"}

        feedback = state
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/changedp', methods=['POST', 'GET'])
def changeDPF():
    try:
        #username, dp, sessionid, fileEx = changedp.getName()
        db, cursor = connectDBServ()
        if request.method == 'POST':
            username = request.form['username']
            fileEx = request.form['extension']
            sessionid = request.form['sessionid']

            username1, email = changedp.auth(db, cursor, sessionid, username)

            if len(username1) == 0:
                status = 'hacker'
                reply = {'status': status}
            elif username1[0][0] == username:
                try:
                    dpFn = username+'.'+fileEx

                    strg = """update usertb set picture=%s where username=%s"""
                    cursor.execute(strg, (dpFn, username))
                    db.commit()

                    reply = {'status': 'ok', 'dpFn': dpFn,
                             'username': username}

                except:
                    reply = {'status': 'failed',
                             'dpFn': dpFn, 'username': username}

                title = "Profile Picture Changed"
                body = """{}, your profile picture has been changed \n\n""".format(
                    username)
                """ updateNotify(db, cursor, nowtime, nowdate,
                             username, body, title, None) """
                """ email_result(username,email,title) """

            elif username1 != username:
                status = 'hacker'
                reply = {'status': status}

        elif request.method == 'GET':
            status = 'hacker'

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/chathistory', methods=['POST', 'GET'])
def chathistoryF(username, sessionid):
    try:
        print('chathistory called...')
        #sessionid, username = chathistory.getName()
        db, cursor = connectDBServ()
        print('kd:1')

        username1 = chathistory.auth(db, cursor, sessionid)

        print('kd:2')
        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
            print('kd:3')
        elif username1[0][0] == username:
            print('kd:4')
            profiles, onlineStatus, last_seen, last_messages = chathistory.retrivProfiles(
                db, cursor, username)
            print('kd:4')
            reply = {'status': 'valid', "profiles": profiles,
                     "onlineStatus": onlineStatus, "last_seen": last_seen,
                     "last_messages": last_messages}
            print('kd:5')

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}
            print('kd:6')

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        # abort()


@app.route('/deletepic', methods=['POST', 'GET'])
def deletepicF(username, showroomid, sessionid):
    try:
        #username, sessionid, showroomid = deletepic.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            showroomid = request.form['showroomid']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            showroomid = request.args.get('showroomid')
            sessionid = request.args.get('sessionid') """

        username1, email = deletepic.auth(db, cursor, sessionid, username)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            #status = deletepic.updt(db, cursor, int(showroomid))

            str = "select photo from showroomtb where showroomid='{}'".format(
                showroomid)
            cursor.execute(str)
            photo = cursor.fetchall()

            if len(photo) == 0:
                status = 'invalid'

            else:
                os.remove(os.path.join(
                    app.config['UPLOAD_FOLDER'], photo[0][0]))

                str = "delete from showroomtb where showroomid='{}'".format(
                    showroomid)
                cursor.execute(str)
                db.commit()

                status = 'deleted'

            title = "Picture Deleted"
            body = """{}, you sucessfully deleted one of your showroom pictures \n\n""".format(
                username)
            updateNotify(db, cursor, nowtime, nowdate,
                         username, body, title, None)
            """ email_result(username,email,title)"""
            reply = {'status': status}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/detailproc', methods=['POST', 'GET'])
def detailprocF(username, trnxid, sessionid):
    try:
        #trnxid, sessionid, username = detailproc.getName()
        db, cursor = connectDBServ()

        username1, usersInvolved = detailproc.auth(
            db, cursor, sessionid, int(trnxid))

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username and (username == usersInvolved[0][0] or username == usersInvolved[0][1]):
            details = detailproc.retrivDetails(db, cursor, int(trnxid))
            if details == "empty":
                reply = {'status': 'invalid'}
            if details != "empty":
                if details[0][0] != username:
                    personal = detailproc.retrivPersonal(
                        db, cursor, details[0][0])
                else:
                    personal = detailproc.retrivPersonal(
                        db, cursor, details[0][1])

                reply = {'status': 'valid',
                         "details": details[0], "personal": personal[0]}

        elif username1 != username or (username != usersInvolved[0][0] or username != usersInvolved[0][1]):
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/finish', methods=['POST', 'GET'])
def finishF(username, trnxid, sessionid, rating, comment):
    try:
        #username, trnxid, sessionid, rating, comment = finish.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            trnxid = request.form['trnxid']
            sessionid = request.form['sessionid']
            rating = request.form['rating']
            comment = request.form['comment']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            trnxid = request.args.get('trnxid')
            sessionid = request.args.get('sessionid')
            rating = request.args.get('rating')
            comment = request.args.get('comment') """

        trnxStatus, username1, client, event_type, planner, events, avg_rating, email = finish.getStatus(
            db, cursor, int(trnxid), sessionid)

        total = sum(events)
        new_avg_rating = ((avg_rating*total)+int(rating))/(total+1)

        if trnxStatus == 'scheduled' and username1 == username and username == client:
            finish.updt(db, cursor, int(trnxid), time_created, username, client,
                        event_type.replace(' ', '_'), planner, int(rating), comment, new_avg_rating)

            title = "Event Completed"
            body = """{}, congratulations, {} marked your event as successfully completed \n\n""".format(
                planner, username)
            """ updateNotify(db, cursor, nowtime, nowdate,
                         username, body, title, int(trnxid)) """
            """ email_result(username,email,title,planner) """

            state = {"status": "valid"}

        elif trnxStatus != 'scheduled' or username1 != username or username != client:
            state = {"status": "Invalid"}

        feedback = state
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/genOtp', methods=['POST', 'GET'])
def genOtpF(username, subject, sessionid):
    try:
        db, cursor = connectDBServ()
        username1, email = genOtp.auth(db, cursor, sessionid, username)

        if len(username1) == 0:
            reply = {'status': 'hacker'}
        elif username == username1[0][0]:
            OTP = genOtp.genOTP()
            genOtp.updt(db, cursor, OTP, username)
            status = genOtp.email_result(username, OTP, email, subject)
            reply = {'status': status}

        elif username != username1[0][0]:
            reply = {'status': 'hacker'}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getchats', methods=['POST', 'GET'])
def getchatsF(username, receiver, sessionid, nextchatid):
    try:
        #sessionid, username, receiver = getchats.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            receiver = request.form['receiver']
            sessionid = request.form['sessionid']
            nextchatid = request.form['nextchatid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            receiver = request.args.get('receiver')
            sessionid = request.args.get('sessionid')
            nextchatid = request.args.get('nextchatid') """

        username1 = getchats.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            chats = getchats.retrivChats(
                db, cursor, username, receiver, int(nextchatid))
            if int(nextchatid) == 0:
                userProfile = getchats.retrivProfile(db, cursor, receiver)
                onlineStatus, last_seen = getOnlineStatus.getOnlineStatus(db, cursor, [
                                                                          receiver])
                reply = {'status': 'valid', "chats": chats,
                         "userProfile": userProfile[0], "onlineStatus": onlineStatus}
            else:
                reply = {'status': 'valid', "chats": chats}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getsettings', methods=['POST', 'GET'])
def getsettingsF(username, sessionid):
    try:
        #sessionid, username = getsettings.getName()
        db, cursor = connectDBServ()

        username1 = getsettings.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            personal = getsettings.retrivPersonal(db, cursor, username)
            if personal[0][2] == 0:
                planner = 'No'
            elif personal[0][2] == 1:
                planner = 'Yes'
            reply = {'status': 'valid',
                     "settings": personal[0], "planner": planner}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/getshowroom', methods=['POST', 'GET'])
def getshowroomF(username, sessionid):
    try:
        #sessionid, username = getshowroom.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid') """

        username1 = getshowroom.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}
        elif username1[0][0] == username:
            showroom = getshowroom.retrivShowroom(db, cursor, username)
            reply = {'status': 'valid', "showroom": showroom}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/hireproc', methods=['POST', 'GET'])
def hireprocF(street, city, state, country, date, type, budget, note, sessionid, username, planner, fee):

    try:
        #street, city, state, country, date, type, budget, note, username, sessionid, planner, fee = hireproc.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            street = request.form['street']
            city = request.form['city']
            state = request.form['state']
            country = request.form['country']
            date = request.form['date']
            type = request.form['type']
            budget = request.form['budget']
            note = request.form['note']
            sessionid = request.form['sessionid']
            username = request.form['username']
            planner = request.form['planner']
            fee = request.form['fee']
        elif request.method == 'GET':
            print('requesting')
            street = request.args.get('street')
            city = request.args.get('city')
            state = request.args.get('state')
            country = request.args.get('country')
            date = request.args.get('date')
            type = request.args.get('type')
            budget = request.args.get('budget')
            note = request.args.get('note')
            sessionid = request.args.get('sessionid')
            username = request.args.get('username')
            planner = request.args.get('planner')
            fee = request.args.get('fee') """

        username1, email = hireproc.auth(db, cursor, sessionid, planner)

        if len(username1) == 0:
            repo = {"status": "hacker"}
        elif len(username1) > 0:
            if username1[0][0] == username:
                available = hireproc.checkAvailable(db, cursor, planner)

                if available[0][0] == 0:
                    repo = {"status": "not available"}
                elif available[0][0] == 1:
                    repo = {"status": "available"}
                    trnxid = hireproc.insert_order(db, cursor, time_created, street, city, state, country, date, type, float(
                        budget), note, username, planner, float(fee))

                    title = "New Order"
                    body = """{}, you have a new service request from {} \n\n""".format(
                        planner, username)
                    """ updateNotify(db, cursor, nowtime, nowdate,
                                 planner, body, title, int(trnxid[0][0])) """
                    """ email_result(username,email,title,planner) """

                    """ notifyCourier(db,cursor,planner, trnxid[0][0], title,body,time_created) """

            elif username1[0][0] != username:
                repo = {"status": "hacker"}

        feedback = repo
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/homeproc', methods=['POST', 'GET'])
def homeprocF(username, sessionID):
    try:
        #username, sessionID = homeproc.getName()
        db, cursor = connectDBServ()

        username1 = homeproc.auth(db, cursor, sessionID)

        # check if the username exists, and password matches that of username
        if len(username1) == 0:  # user does not exist
            login = "hacker"
        # user exists and the password matches the user's password
        elif username == username1[0][0]:
            login = "valid"
        else:  # password does not match username's password
            login = "hacker"

        # if username and password matches
        if login == "valid":
            personal = homeproc.regular_stuff(db, cursor, username)
            updateLastSeen.updateLastSeen(db, cursor, username)
            pending, scheduled, completed = homeproc.getOrders(
                cursor, username)
            pendingPics = homeproc.profilePics(
                db, cursor, username, pending)
            scheduledPics = homeproc.profilePics(
                db, cursor, username, scheduled)
            completedPics = homeproc.profilePics(
                db, cursor, username, completed)

            response = {'login': login, 'sessionID': sessionID, 'personal': personal,
                        'pending': pending, 'scheduled': scheduled, 'completed': completed,
                        'pendingPics': pendingPics, 'scheduledPics': scheduledPics,
                        'completedPics': completedPics}

        elif login == "hacker":
            response = {"login": login}

        feedback = response
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback, login
    except:
        db.close()
        abort()


@app.route('/logout', methods=['POST', 'GET'])
def logoutF(username, sessionid):
    try:
        #sessionid, username = logout.getName()
        db, cursor = connectDBServ()

        username1 = logout.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}

        elif username1[0][0] == username:
            logout.deleteRecord(db, cursor, sessionid)

            reply = {"status": "valid"}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        # abort()


@app.route('/ordproc', methods=['POST', 'GET'])
def ordprocF(username, sessionid, budget):
    try:
        #username, sessionid, budget = ordproc.getName()
        db, cursor = connectDBServ()

        username1 = ordproc.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            qualifiedDetails = {'status': status}
        elif username1[0][0] == username:
            available, showroom, hit = ordproc.retrivAvailable(
                db, cursor, username)
            if hit == 'yes':
                qualifiedDetails = {'status': 'valid', 'available': available, 'showroom': showroom, 'hit': hit, 'qty': len(
                    available), 'budget': float(budget)}
            elif hit == 'no':
                qualifiedDetails = {'status': 'valid', 'hit': hit}

        elif username1 != username:
            status = 'hacker'
            qualifiedDetails = {'status': status}

        feedback = qualifiedDetails
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/passwordotp', methods=['POST', 'GET'])
def passwordotpF(username, subject):
    try:
        #username, subject = passwordotp.getName()
        db, cursor = connectDBServ()

        email = passwordotp.auth(db, cursor, username)

        if len(email) == 0:
            reply = {'status': 'invalid'}
        elif len(email) > 0:
            OTP = passwordotp.genOTP()
            passwordotp.updt(db, cursor, OTP, username)
            status = passwordotp.email_result(
                username, OTP, email[0][0], subject)
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/plannerdetails', methods=['POST', 'GET'])
def plannerdetailsF(username, planner, sessionid):
    try:
        #username, sessionid, planner = plannerdetails.getName()
        db, cursor = connectDBServ()

        username1 = plannerdetails.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}

        elif username1[0][0] == username:
            details, reviews, client_pics = plannerdetails.get_details(
                db, cursor, planner)
            reply = {'status': 'valid', 'details': details, 'reviews': reviews,
                     'client_pics': client_pics}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/regproc', methods=['POST', 'GET'])
def regprocF(usern, passwd, email1, gender):
    # try:
    print("regprocF...")
    #values = regproc.getName()
    db, cursor = connectDBServ()
    #values = [usern, passwd, email, gender]

    username, email = regproc.verify(db, cursor, usern, email1)
    _username = 'available'
    _email = 'available'

    if len(username) == 0 and len(email) == 0:
        sessID, log_time = regproc.changeID(
            db, cursor, usern, 'deviceid', 'deviceToken')
        regproc.insrt(
            db, cursor, usern, passwd, email1, gender, log_time)

        url = "http://ikp120.pythonanywhere.com/adduser"
        param = {'username': usern, 'password': passwd, 'email': email1,
                 'gender': gender, 'sessionid': sessID, 'deviceID': 'unknown',
                 'deviceToken': 'unknown'}

        pyResp = requests.post(url, data=param)
        #js = json.loads(pyResp.text)
        # print(js['login'])

        updateLastSeen.updateLastSeen(db, cursor, username)
        title = "Welcome to eventGig"
        body = """{}, welcome to eventGig \n\n""".format(username)
        updateNotify(db, cursor, nowtime, nowdate,
                     usern, body, title, None)

        #regproc.email_result(values[0], values[2], title)
        valid = "yes"
        reply = {"valid": "yes", 'email': _email,
                 'username': _username, 'sessID': sessID}
        # sess={"pending":"empty","picked":"empty","history":"empty","admin":False,
        #      "delivered":"empty","verify":[[0,0,'empty','empty','empty']],"name":1,'phone':1,'photo':'empty', 'sessID':sessID,'business':False, 'dependent':False}
    else:

        if len(username) > 0:
            _username = 'taken'
        if len(email) > 0:
            _email = 'taken'
        valid = "no"
        reply = {"valid": "no", 'email': _email, 'username': _username}
        # sess={"pending":"empty","verify":"empty","name":_name,'phone':_phone,'business':False,'dependent':False}

    feedback = reply
    db.close()
    #feedback.headers['Access-Control-Allow-Origin'] = '*'
    return feedback, valid
    # except Exception as e:
    #    db.close()
    #    return {'error': e}, 'error'
    # abort()


@app.route('/rejjobproc', methods=['POST', 'GET'])
def rejjobprocF(username, sessionid, trnxid):
    try:
        #username, trnxid, sessionid = rejjobproc.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            sessionid = request.form['sessionid']
            trnxid = request.form['trnxid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid')
            trnxid = request.args.get('trnxid') """

        trnxStatus, username1, client = rejjobproc.getStatus(
            db, cursor, int(trnxid), sessionid)

        if trnxStatus == 'pending' and username1 == username and username != client:
            rejjobproc.updt(db, cursor, int(trnxid),
                            time_created, username, client)
            title = "Order REJECTED"
            body = "{} rejected your order".format(username)
            """ updateNotify(db, cursor, nowtime, nowdate,
                         client, body, title, int(trnxid)) """

            state = {"status": "valid"}

        elif trnxStatus != 'initial' or username1 != username or username == client:
            state = {"status": "Invalid"}

        feedback = state
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/resetpassword', methods=['POST', 'GET'])
def resetpasswordF(username, otp, password):
    try:
        #username, otp, password = resetpassword.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            otp = request.form['otp']
            password = request.form['password']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            otp = request.args.get('otp')
            password = request.args.get('password') """

        email = resetpassword.auth(db, cursor, username)

        if len(email) == 0:
            reply = {'status': 'hacker'}
        elif len(email) > 0:
            if otp == str(email[0][1]):
                resetpassword.updt(db, cursor, username, password)
                resetpassword.email_result(username, email[0][0])
                title = 'Password Changed'
                body = """{}, your password has been successfully changed \n\n""".format(
                    username)
                updateNotify(db, cursor, nowtime, nowdate,
                             username, body, title, None)
                reply = {'status': 'changed'}
            elif otp != str(email[0][1]):
                reply = {'status': 'invalid'}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


def getLastSeen(username, users, sessionid):
    try:
        db, cursor = connectDBServ()

        username1 = savesettings.auth(db, cursor, sessionid)

        if len(username1) == 0:
            reply = {"status": "hacker"}
        elif len(username1) > 0:
            if username1[0][0] == username:
                vals = {}
                for j in users:
                    strg = """select last_seen from usertb where username=%s"""
                    cursor.execute(strg, (j,))
                    k = cursor.fetchall()
                    vals[j] = k[0][0]

                reply = {'status': 'valid', 'last_seen': vals}

            elif username1[0][0] != username:
                reply = {"status": "hacker"}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()


@app.route('/savesettings', methods=['POST', 'GET'])
def savesettingsF(email, phone, profilePic, terms, username, sessionid, planner, fee):
    try:
        #email, phone, profilePic, terms, username, sessionid, planner, fee = savesettings.getName()
        db, cursor = connectDBServ()

        username1 = savesettings.auth(db, cursor, sessionid)

        if len(username1) == 0:
            reply = {"status": "hacker"}
        elif len(username1) > 0:
            if username1[0][0] == username:
                if planner == 'Yes':
                    planner = 1
                elif planner == 'No':
                    planner = 0
                savesettings.insert_order(db, cursor, username, email, phone,
                                          profilePic, terms, planner, float(fee))

                title = "Settings Changed"
                body = "You changed the settings"
                """ updateNotify(db, cursor, nowtime, nowdate,
                             username, body, title, None) """

                reply = {"status": "available"}
                """  notifyuser.send_notification(
                    db, cursor, sessionid, title, body) """

                """ notifyCourier(db,cursor,planner, trnxid[0][0], title,body,time_created) """

            elif username1[0][0] != username:
                reply = {"status": "hacker"}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/sendchat', methods=['POST', 'GET'])
def sendchatF(message, receiver, username, sessionid):
    try:
        #message, receiver, username, sessionid = sendchat.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            message = request.form['message']
            receiver = request.form['receiver']
            username = request.form['username']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            message = request.args.get('message')
            receiver = request.args.get('receiver')
            username = request.args.get('username')
            sessionid = request.args.get('sessionid') """

        username1, email = sendchat.auth(db, cursor, sessionid, receiver)

        if len(username1) == 0:
            reply = {"status": "hacker"}
        elif len(username1) > 0:
            if username1[0][0] == username:
                chatid, time, date, seen = sendchat.insert_message(
                    db, cursor, receiver, message, username, nowdate, nowtime)

                title = "New Message"
                body = """You have a new message from {} \n\n""".format(
                    username)
                """ updateNotify(db, cursor, nowtime, nowdate,
                             receiver, body, title, None) """

                """ sendchat.email_result(username, email, title) """
                status = 'sent'
                reply = {'status': status, 'chatid': chatid,
                         'time': time, 'date': date, 'seen': seen}

                """ notifyCourier(db,cursor,planner, trnxid[0][0], title,body,time_created) """

            elif username1[0][0] != username:
                reply = {"status": "hacker"}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/uploadpic', methods=['POST', 'GET'])
def uploadpicF():
    try:
        #username, dp, sessionid, fileEx = uploadpic.getName()
        db, cursor = connectDBServ()
        if request.method == 'POST':
            print('requesting')
            fileEx = request.form['extension']
            username = request.form['username']
            sessionid = request.form['sessionid']

            username1, email = uploadpic.auth(db, cursor, sessionid, username)

            """ reply={'status':dp.filename} """

            if len(username1) == 0:
                status = 'hacker'
                reply = {'status': status}
            elif username1[0][0] == username:
                #reply = uploadpic.savePic(db, cursor, username, dp, fileEx)

                strg = """insert into showroomtb (username,photo) values (%s,%s) returning showroomid"""
                showroomid = cursor.execute(strg, (username, ""))
                db.commit()

                """ strg = "select last_insert_id()"
                cursor.execute(strg)
                showroomid = cursor.fetchall() """

                fname = username + str(showroomid[0][0])
                dpFn = fname+'.'+fileEx

                strg = """update showroomtb set photo=%s where showroomid=%s"""
                cursor.execute(strg, (dpFn, showroomid[0][0]))
                db.commit()

                reply = {'status': 'ok', 'dpFn': dpFn,
                         'username': username}

                """ try:
                    " dpFn=os.path.basename(dp.filename) "
                    dpFn = fname+'.'+fileEx
                    dp.save(os.path.join(app.config['UPLOAD_FOLDER'], dpFn))

                    strg = "update showroomtb set photo=%s where showroomid=%s"
                    cursor.execute(strg, (dpFn, showroomid[0][0]))
                    db.commit()

                    reply = {'status': 'ok', 'dpFn': dpFn,
                             'username': username}

                except:
                    reply = {'status': 'failed1',
                             'dpFn': dpFn, 'username': username} """

                title = "Picture Added"
                textMsg = """{}, you have added a new picture to your showroom \n\n""".format(
                    username)
                """ updateNotify(db, cursor, nowtime, nowdate,
                             username, body, title, None) """
                #uploadpic.email_result(username, email, title)

            elif username1 != username:
                status = 'hacker'
                reply = {'status': status}

        elif request.method == 'GET':
            status = 'hacker'

        feedback = Response(json.dumps(reply))
        db.close()
        feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/userdetails', methods=['POST', 'GET'])
def userdetailsF(username, user, sessionid):
    try:
        #username, sessionid, planner = plannerdetails.getName()
        db, cursor = connectDBServ()
        """ if request.method == 'POST':
            print('requesting')
            username = request.form['username']
            user = request.form['user']
            sessionid = request.form['sessionid']
        elif request.method == 'GET':
            print('requesting')
            username = request.args.get('username')
            user = request.args.get('user')
            sessionid = request.args.get('sessionid') """

        username1 = userdetails.auth(db, cursor, sessionid)

        if len(username1) == 0:
            status = 'hacker'
            reply = {'status': status}

        elif username1[0][0] == username:
            details, reviews, client_pics, showroom = userdetails.get_details(
                db, cursor, user)
            reply = {'status': 'valid', 'details': details, 'reviews': reviews,
                     'client_pics': client_pics, 'showroom': showroom}

        elif username1 != username:
            status = 'hacker'
            reply = {'status': status}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/verifyOtp', methods=['POST', 'GET'])
def verifyotpF(otp, username, sessionid):
    try:
        #username, sessionid, otp = verifyotp.getName()
        db, cursor = connectDBServ()

        username1, email, OTP1 = verifyotp.auth(
            db, cursor, sessionid, username)

        if len(username1) == 0:
            reply = {'status': 'hacker'}
        elif username == username1[0][0]:
            if int(otp) == OTP1:
                verifyotp.updt(db, cursor, username)
                verifyotp.email_result(username, email)
                body = """{}, your email has been successfully verified \n\n""".format(
                    username)
                title = 'Email Verified'
                """ updateNotify(db, cursor, nowtime, nowdate,
                             username, body, title, None) """
                reply = {'status': "verified"}
            elif otp != OTP1:
                reply = {'status': 'invalid'}

        elif username != username1[0][0]:
            reply = {'status': 'hacker'}

        feedback = reply
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/login', methods=['POST', 'GET'])
def loginProcessor(username, password):
    try:
        db, cursor = connectDBServ()
        password_ = loginproc.get_password(cursor, username)

        # check if the username exists, and password matches that of username
        if len(password_) == 0:  # user does not exist
            print('user does not exist')
            login = "invalid"
        # user exists and the password matches the user's password
        elif password == password_[0][0]:
            print('all is good')
            login = "valid"
        else:  # password does not match username's password
            print('password does not match username')
            login = "invalid"

        # if username and password matches

        response = {"login": login}

        feedback = response
        db.close()
        #feedback.headers['Access-Control-Allow-Origin'] = '*'
        return feedback
    except:
        db.close()
        abort()


@app.route('/savesession', methods=['POST', 'GET'])
def saveSessionF(username, password, deviceid, deviceToken):
    # try:
    db, cursor = connectDBServ()
    password_ = loginproc.get_password(cursor, username)

    # check if the username exists, and password matches that of username
    if len(password_) == 0:  # user does not exist
        print('user does not exist')
        login = "invalid"
    # user exists and the password matches the user's password
    elif password == password_[0][0]:
        print("user exists and the password matches the user's password")
        login = "valid"
    else:  # password does not match username's password
        print("password does not match username's password")
        login = "invalid"

    # if username and password matches
    if login == "valid":
        print("id:1")
        # generate new session token for user
        sessionID = loginproc.changeID(
            db, cursor, username, deviceid, deviceToken)
        print("id:2")

        url = "http://ikp120.pythonanywhere.com/loginuser"
        param = {'username': username, 'password': password, 'sessionid': sessionID,
                 'deviceid': 'unknown', 'deviceToken': 'unknown'}

        pyResp = requests.post(url, data=param)
        #js = json.loads(pyResp.text)
        # print(js['login'])

        #updateLastSeen.updateLastSeen(db, cursor, username)
        print("id:3")
        personal = loginproc.regular_stuff(db, cursor, username)
        print("id:4")
        pending, scheduled, completed = loginproc.getOrders(
            cursor, username)
        print("id:5")
        pendingPics = loginproc.profilePics(db, cursor, username, pending)
        print("id:6")
        scheduledPics = loginproc.profilePics(
            db, cursor, username, scheduled)
        print("id:7")
        completedPics = loginproc.profilePics(
            db, cursor, username, completed)
        print("id:8")
        title = "New Login"
        #loginproc.email_result(username, personal[0][0], title)

        body = """{}, a device just logged into your account""".format(
            username)

        updateNotify(db, cursor, nowtime, nowdate,
                     username, body, title, None)
        print("id:9")

        response = {'login': login, 'sessionID': sessionID, 'personal': personal,
                    'pending': pending, 'scheduled': scheduled, 'completed': completed,
                    'pendingPics': pendingPics, 'scheduledPics': scheduledPics,
                    'completedPics': completedPics}

    elif login == "invalid":
        print("id:10")
        response = {"login": login}

    feedback = response
    db.close()
    #feedback.headers['Access-Control-Allow-Origin'] = '*'
    return feedback, login
    # except:
    #    db.close()
    # abort()


""" if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True) """
