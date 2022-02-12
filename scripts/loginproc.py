# loginproc.py

import cgi
import json
from codecs import decode
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import random
import datetime
import hashlib
#import mysql.connector as conn
#from pyfcm import FCMNotification

from . import notifyusers
from . import notifyusersFBA

# extract data from submited form that has process.cgi as its action attribute


""" def getName():
    formData = cgi.FieldStorage()
    username = formData.getvalue('username')
    password = formData.getvalue('password')
    return username, password
 """
# connect to database


""" def connectDBServ():
    db = conn.connect(host="localhost", user="root", passwd="", db="eventdb")
    cursor = db.cursor()
    return db, cursor
 """
# get password and user classification of the user


def get_password(cursor, username):
    str = """select password from usertb where username = %s"""
    cursor.execute(str, (username,))
    password_ = cursor.fetchall()
    return password_

# get pending, picked, delivered, and history of the user


def getOrders(cursor, username):
    print('j:1')
    str = """select time_created, event_type, event_date, budget, trnxid,client,planner from trnxtb where (planner=%s and status ='pending')
     or (client=%s and status='pending')"""
    cursor.execute(str, (username, username))
    print('j:2')
    pending = cursor.fetchall()

    str = """select event_date, event_type, budget, fee, trnxid,client,planner from trnxtb where (planner=%s and status ='scheduled')
     or (client=%s and status='scheduled')"""
    cursor.execute(str, (username, username))
    print('j:3')
    scheduled = cursor.fetchall()

    str = """select  time_completed, event_type, rating,comment, trnxid,client,planner from trnxtb where (planner=%s and status ='completed')
     or (client=%s and status='completed')"""
    cursor.execute(str, (username, username))
    print('j:4')
    completed = cursor.fetchall()

    return pending, scheduled, completed

# generate new session ID, and time, and create new session for the user


def changeID(db, cursor, username, deviceid, deviceToken):
    num1 = random.randint(3, 8)
    num2 = random.randint(1, 5)
    num3 = random.randint(2, 6)
    num4 = random.randint(5, 9)
    num5 = random.randint(0, 7)
    num6 = random.randint(3, 9)
    numstr = str(num1)+str(num2)+str(num3)+str(num4)+str(num5)+str(num6)
    val = (random.choice(numstr))+(random.choice(numstr))+(random.choice(numstr)) + \
        (random.choice(numstr))+(random.choice(numstr))+(random.choice(numstr))

    x = datetime.datetime.now()
    nowtime = x.strftime('%I')+':'+x.strftime('%M')+' '+x.strftime('%p')
    nowdate = x.strftime('%d')+'-'+x.strftime('%b')+'-'+x.strftime('%Y')
    login_time = nowdate+'  '+nowtime

    seed = username+'89jhasjk7kppg776jjakrklu6578hgjh'+login_time+str(val)
    hashval = hashlib.sha256(seed.encode())
    sessionid = hashval.hexdigest()

    strg = """insert into logintb (username,login_time,sessionid, deviceid, deviceToken) values (%s,%s,%s,%s,%s)"""
    cursor.execute(strg, (username, login_time,
                   sessionid, deviceid, deviceToken))
    db.commit()

    title = "New Login"
    """ email_result(username,personal[0][0],title) """

    body = """{}, a device just logged into your account""".format(
        username)

   # push_service = FCMNotification(api_key="AAAATBN4kNU:APA91bFsdNgN_pSfzJ6UAib9ETxGYfflhYbjf4LysBV4q5IkNVmgifWksjZfxLZc907aaOSTNp_JOZOjZk-EfqhKTuQ-VV-W9NL0AdTxp4KFoUv9AJtq-xldSoGwFnQj9X-HNtJIrbOn")

    #result = push_service.notify_single_device(registration_id=deviceToken,message_title=title, message_body=body)

    #result1 = notifyusersFBA.send_notif(db, cursor, username, title, body)

    return sessionid


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

        textMsg = """{}, a device just logged into your account \n\n""".format(
            username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

        """return 'sent' """


def updateNotify(db, cursor, time, date, receiver, body, title):
    strg = """insert into notifytb (time,date,receiver,body,seen,title) values (%s,%s,%s,%s,%s,%s)"""
    cursor.execute(strg, (time, date, receiver, body, 0, title))
    db.commit()


def regular_stuff(db, cursor, username):
    # get user's account data
    str = """select email, phone,picture,verified,gender from usertb where username=%s"""
    cursor.execute(str, (username,))
    personal = cursor.fetchall()

    return personal


def profilePics(db, cursor, username, trnx):
    # get user's account data
    dps = []
    for trn in trnx:
        if username == trn[6]:
            user = trn[5]
        else:
            user = trn[6]
        str = """select picture from usertb where username=%s"""
        cursor.execute(str, (user,))
        picture = cursor.fetchall()
        dps.append(picture)

    return dps
