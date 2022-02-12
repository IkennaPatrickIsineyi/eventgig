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
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def genOTP():
    num1 = random.randint(3, 8)
    num2 = random.randint(1, 5)
    num3 = random.randint(2, 6)
    num4 = random.randint(5, 9)
    num5 = random.randint(0, 7)
    num6 = random.randint(3, 9)
    numstr = str(num1)+str(num2)+str(num3)+str(num4)+str(num5)+str(num6)
    OTP = (random.choice(numstr))+(random.choice(numstr))+(random.choice(numstr)) + \
        (random.choice(numstr))+(random.choice(numstr))+(random.choice(numstr))

    return OTP


def updt(db, cursor, OTP, username):
    # update senderOTP column in trnxtb where trnxID=trnxid
    str = """update usertb set otp=%s where username=%s"""
    cursor.execute(str, (OTP, username))
    db.commit()


def email_result(username, OTP, email, subject):
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

        textMsg = """{}, your {} is \n\n{}""".format(username, subject, OTP)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    return 'sent'


def auth(db, cursor, sessionid, username):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select email from usertb where username=%s"""
    cursor.execute(str, (username,))
    email = cursor.fetchall()

    return username1, email[0][0]
