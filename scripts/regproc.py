#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


import random

import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

import datetime
import hashlib
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def insrt(db, cursor, usern, passwd, email, gender, log_time):
    print("insert called")
    str = """insert into usertb (username, password, email, gender,date_created)
     values (%s,%s,%s, %s,%s)"""
    cursor.execute(str, (usern, passwd, email, gender, log_time))
    db.commit()


def changeID(db, cursor, username, deviceid, deviceToken):
    print('changeid called')
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
    log_time = nowdate+'  '+nowtime

    seed = username+'89jhasjk7kppg776jjakrklu6578hgjh'+log_time+str(val)
    hashval = hashlib.sha256(seed.encode())
    sessID = hashval.hexdigest()

    strg = """insert into logintb (username,login_time,sessionid,deviceid,deviceToken) values (%s,%s,%s,%s,%s)"""
    cursor.execute(strg, (username, log_time, sessID, deviceid, deviceToken))
    db.commit()

    return sessID, log_time


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

        textMsg = """{}, welcome to eventGig \n\n""".format(username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    """ return 'sent' """


def verify(db, cursor, usern, email):
    print("verify called")
    str = """select * from usertb where username= %s"""
    cursor.execute(str, (usern,))
    username = cursor.fetchall()

    str = """select * from usertb where email=%s"""
    cursor.execute(str, (email,))
    email = cursor.fetchall()
    print(username)
    print(email)
    return username, email
