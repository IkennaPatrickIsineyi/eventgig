#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
import random
import os
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import datetime
import requests
# mport mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def updt(db, cursor, showroomid):
    # update senderOTP column in trnxtb where trnxID=trnxid
    str = """select photo from showroomtb where showroomid=%s"""
    cursor.execute(str, (showroomid,))
    photo = cursor.fetchall()

    if len(photo) == 0:
        return 'invalid'

    else:
        os.remove(photo[0][0])

        str = """delete from showroomtb where showroomid=%s"""
        cursor.execute(str, (showroomid,))
        db.commit()

        return 'deleted'


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

        textMsg = """{}, you sucessfully deleted one of your showroom pictures \n\n""".format(
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
