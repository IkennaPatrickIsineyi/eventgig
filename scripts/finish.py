#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import datetime
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def updt(db, cursor, trnxid, time_notified, username, client, event_type, planner, rating, comment, new_avg_rating):
    str = """update trnxtb set status='completed', time_completed=%s,rating=%s,
    comment=%s where trnxID=%s"""
    cursor.execute(str, (time_notified, rating, comment, trnxid))
    db.commit()

    strg = """update usertb set %s=%s+1 where username=%s or username=%s"""
    cursor.execute(strg, (event_type, event_type, username, planner))
    db.commit()

    str = """update usertb set rating=%s,avg_rating=%s where username=%s"""
    cursor.execute(str, (int(new_avg_rating), new_avg_rating, planner))
    db.commit()


def email_result(username, email, subject, planner):
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

        textMsg = """{}, congratulations, {} marked your event as successfully completed \n\n""".format(
            planner, username)

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


def getStatus(db, cursor, trnxid, sessionid):
    str = """select status,client,event_type,planner from trnxtb where trnxID=%s"""
    cursor.execute(str, (trnxid,))
    trnxStatus = cursor.fetchall()

    str = """select username from logintb where sessionID=%s"""
    cursor.execute(str, (sessionid,))
    username = cursor.fetchall()

    str = """select birthday,school_event,wedding, house_warming,peagent,
    seminar, burial,others from usertb where username=%s"""
    cursor.execute(str, (trnxStatus[0][3],))
    events = cursor.fetchall()

    str = """select avg_rating,email from usertb where username=%s"""
    cursor.execute(str, (trnxStatus[0][3],))
    avg_rating = cursor.fetchall()

    return trnxStatus[0][0], username[0][0], trnxStatus[0][1], trnxStatus[0][2], trnxStatus[0][3], events[0], avg_rating[0][0], avg_rating[0][1]
