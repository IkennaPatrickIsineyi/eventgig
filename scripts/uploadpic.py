#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import os
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import json
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def savePic(db, cursor, username, dp, fileEx):
    strg = """insert into showroomtb (username) values (%s) returning showroomid"""
    cursor.execute(strg, (username,))
    showroomid = cursor.fetchall()
    db.commit()

    fname = username + str(showroomid[0][0])

    try:
        """ dpFn=os.path.basename(dp.filename) """
        dpFn = os.path.basename(fname+'.'+fileEx)
        open(dpFn, 'wb').write(dp.file.read())

        strg = """update showroomtb set photo=%s where showroomid=%s"""
        cursor.execute(strg, (dpFn, showroomid[0][0]))
        db.commit()

        state = {'status': 'ok', 'dpFn': dpFn, 'username': username}

    except:
        state = {'status': 'failed1', 'dpFn': dpFn, 'username': username}

    return state


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

        textMsg = """{}, you have added a new picture to your showroom \n\n""".format(
            username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    """ return 'sent' """


def auth(db, cursor, sessionid, username):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select email from usertb where username=%s"""
    cursor.execute(str, (username,))
    email = cursor.fetchall()

    return username1, email[0][0]
