#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
import datetime
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def getName():
    formData = cgi.FieldStorage()
    username = formData.getvalue('username')
    trnxid = formData.getvalue('trnxid')
    sessionid = formData.getvalue('sessionid')

    return username, trnxid, sessionid


def updt(db, cursor, trnxid, time_notified, username, client):
    str = """update trnxtb set status='canceled', time_cancelled=%s where trnxID=%s"""
    cursor.execute(str, (time_notified, trnxid))
    db.commit()


def email_result(username, email, subject, victim):
    sender_email = 'developerdeveloper150@gmail.com'
    password = 'rhrrbsnfbtzpxjti'
    subject = subject
    receiver = email

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['To'] = receiver
    msg['From'] = sender_email

    context = ssl.create_default_context()

    # Text format of email body and send the email
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as server:
        server.login(sender_email, password)

        textMsg = """{}, unfortunately, your event was cancelled by {} \n\n""".format(
            victim, username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    """ return 'sent' """

    """ title="Congratulation! Event Completed"
    body="{} marked your event as completed".format(username)
    
    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,client,time_notified,title,body,0)
    cursor.execute(str)
    db.commit() """

    """ title="Event CANCELED"
    body="{} canceled the event".format(username)
    
    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,client,time_notified,title,body,0)
    cursor.execute(str)
    db.commit() """


def getStatus(db, cursor, trnxid, sessionid):
    str = """select status,client,planner from trnxtb where trnxID=%s"""
    cursor.execute(str, (trnxid,))
    trnxStatus = cursor.fetchall()

    str = """select username from logintb where sessionID=%s"""
    cursor.execute(str, (sessionid,))
    username = cursor.fetchall()

    if username[0][0] == trnxStatus[0][1]:
        cancBy = trnxStatus[0][1]
        victim = trnxStatus[0][2]
    elif username[0][0] == trnxStatus[0][2]:
        cancBy = trnxStatus[0][2]
        victim = trnxStatus[0][1]

    str = """select email from usertb where username=%s"""
    cursor.execute(str, (victim,))
    email = cursor.fetchall()

    return trnxStatus[0][0], username[0][0], trnxStatus[0][1], email[0][0], victim
