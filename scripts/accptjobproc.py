#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
import datetime
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def getName():
    formData = cgi.FieldStorage()
    username = formData.getvalue('username')
    trnxid = formData.getvalue('trnxid')
    sessionid = formData.getvalue('sessionid')

    return username, trnxid, sessionid


""" def connectDBServ():
    db = conn.connect(host="localhost", user="root", passwd="", db="eventdb")
    cursor = db.cursor()
    return db, cursor """


def updt(db, cursor, trnxid, time_notified, username, client):
    str = """update trnxtb set status='scheduled', time_accepted=%s where trnxID=%s"""
    cursor.execute(str, (time_notified, trnxid))
    db.commit()

    """ title="Order ACCEPTED"
    body="{} accepted your order".format(username)
    
    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,client,time_notified,title,body,0)
    cursor.execute(str)
    db.commit() """


def getStatus(db, cursor, trnxid, sessionid):
    str = """select status,client from trnxtb where trnxID=%s"""
    cursor.execute(str, (trnxid,))
    trnxStatus = cursor.fetchall()

    str = """select username from logintb where sessionID=%s"""
    cursor.execute(str, (sessionid,))
    username = cursor.fetchall()

    return trnxStatus[0][0], username[0][0], trnxStatus[0][1]


""" # main program
if __name__ == "__main__":
    try:
        username, trnxid, sessionid = getName()
        db, cursor = connectDBServ()
        trnxStatus, username1, client = getStatus(
            db, cursor, int(trnxid), sessionid)

        if trnxStatus == 'pending' and username1 == username and username != client:
            x = datetime.datetime.now()
            nowtime = x.strftime('%I')+':' + \
                x.strftime('%M')+' '+x.strftime('%p')
            nowdate = x.strftime('%d')+'-' + \
                x.strftime('%b')+'-'+x.strftime('%Y')
            time_notified = nowdate+'  '+nowtime

            updt(db, cursor, int(trnxid), time_notified, username, client)

            state = {"status": "valid"}

        elif trnxStatus != 'initial' or username1 != username or username == client:
            state = {"status": "Invalid"}

        print("Access-Control-Allow-Origin:*")
        print("Content-Type:text/plain\r\n")
        # print("content_type:application/json\n\n")
        print(json.dumps(state))
    except:
        cgi.print_exception()
 """
