#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import json
import random
import datetime
from dotenv import load_dotenv
import os

load_dotenv('.env')
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def updt(db, cursor, username):
    # update senderOTP column in trnxtb where trnxID=trnxid
    str = """update usertb set otp=%s, verified=1 where username=%s"""
    cursor.execute(str, (0, username))
    db.commit()


def email_result(username, email):
    sender_email = 'developerdeveloper150@gmail.com'
    password = os.getenv('EMAIL_TOKEN')
    subject = 'Email Verified'
    receiver = email

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['To'] = receiver
    msg['From'] = sender_email

    context = ssl.create_default_context()

    # Text format of email body and send the email
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as server:
        server.login(sender_email, password)

        textMsg = """{}, your email has been successfully verified \n\n""".format(
            username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

        """return 'verified'"""


def auth(db, cursor, sessionid, username):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select email,otp from usertb where username=%s"""
    cursor.execute(str, (username,))
    email = cursor.fetchall()

    return username1, email[0][0], email[0][1]
