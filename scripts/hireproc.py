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


def checkAvailable(db, cursor, planner):
    str = """select planner from usertb where username=%s"""
    cursor.execute(str, (planner,))
    available = cursor.fetchall()

    return available


def insert_order(db, cursor, time_created, street, city, state, country, date, type, budget, note, username, planner, fee):
    #str="update trnxtb set courier='{}', status='initial' where sender='{}' and trnxID='{}'".format(courier,sender, trnxid)

    strg = """insert into trnxtb (time_created,street,city,state
    ,country,event_date,event_type,budget,note,client,planner,fee,status) values (%s,%s,
    %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'pending') returning trnxid"""
    cursor.execute(strg, (time_created, street, city, state,
                   country, date, type, budget, note, username, planner, fee))
    db.commit()

    trnxid = cursor.fetchall()

    return trnxid


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

        textMsg = """{}, you have a new service request from {} \n\n""".format(
            planner, username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    """ return 'sent' """


""" def notifyCourier(db,cursor,courier,trnxid,title,body,time_created):
    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,courier,time_created,title,body,0)
    
    cursor.execute(str)
    db.commit() """
"""     str="update couriertb set oncall= '{}', available='{}' , newdeal='{}' where username='{}'".format('1','1',trnxid,courier)
    cursor.execute(str)
    db.commit()
 """


def auth(db, cursor, sessionid, planner):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select email from usertb where username=%s"""
    cursor.execute(str, (planner,))
    email = cursor.fetchall()

    return username1, email[0][0]
