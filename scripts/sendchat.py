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
from datetime import datetime
#import mysql.connector as conn

# creates new order and returns all the qualified and available couriers for the order


def insert_message(db, cursor, receiver, message, username, date, time):
    #str="update trnxtb set courier='{}', status='initial' where sender='{}' and trnxID='{}'".format(courier,sender, trnxid)
    x = datetime.now()
    nowtime = x.strftime('%I')+':' + \
        x.strftime('%M')+' '+x.strftime('%p')
    nowdate = x.strftime('%d')+'-' + \
        x.strftime('%b')+'-'+x.strftime('%Y')
    time_created = nowdate+'  '+nowtime

    param = (nowtime, nowdate, receiver, message, username, 0)

    strg = """insert into chattb (time,date,receiver,message,sender,seen) values (%s,%s,%s,%s,%s,%s) returning chatid,time,date,seen"""

    cursor.execute(strg, param)
    chatid = cursor.fetchall()
    db.commit()

    return chatid[0][0], chatid[0][1], chatid[0][2], chatid[0][3]


def email_result(username, email, subject):
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

        textMsg = """You have a new message from {} \n\n""".format(username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    return 'sent'


""" def notifyCourier(db,cursor,courier,trnxid,title,body,time_created):
    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,courier,time_created,title,body,0)

    cursor.execute(str)
    db.commit() """
"""     str="update couriertb set oncall= '{}', available='{}' , newdeal='{}' where username='{}'".format('1','1',trnxid,courier)
    cursor.execute(str)
    db.commit()
 """


def auth(db, cursor, sessionid, receiver):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select email from usertb where username=%s"""
    cursor.execute(str, (receiver,))
    email = cursor.fetchall()

    return username1, email[0][0]
