#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


#import mysql.connector as conn

import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


# extract data from submited form that has process.cgi as its action attribute


def updt(db, cursor, trnxid, time_notified, username, client):
    str = """update trnxtb set status='rejected' where trnxID=%s"""
    cursor.execute(str, (trnxid,))
    db.commit()

    """ title="Order REJECTED"
    body="{} rejected your order".format(username)

    str='''insert into notifytb (trnxid, sent_to, time_received, title, body, seen)
    values ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(trnxid,client,time_notified,title,body,0)
    cursor.execute(str)
    db.commit() """


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

        textMsg = "{} rejected your order".format(username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    """ return 'sent' """


def getStatus(db, cursor, trnxid, sessionid):
    str = """select status,client from trnxtb where trnxID=%s"""
    cursor.execute(str, (trnxid,))
    trnxStatus = cursor.fetchall()

    str = """select username from logintb where sessionID=%s"""
    cursor.execute(str, (sessionid,))
    username = cursor.fetchall()

    return trnxStatus[0][0], username[0][0], trnxStatus[0][1]
