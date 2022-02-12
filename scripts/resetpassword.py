#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def updt(db, cursor, username, password):
    # update senderOTP column in trnxtb where trnxID=trnxid
    str = """update usertb set otp=%s,password=%s where username=%s"""
    cursor.execute(str, (0, password, username))
    db.commit()


def email_result(username, email):
    sender_email = 'developerdeveloper150@gmail.com'
    password = 'rhrrbsnfbtzpxjti'
    subject = 'Password Changed'
    receiver = email

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['To'] = receiver
    msg['From'] = sender_email

    context = ssl.create_default_context()

    # Text format of email body and send the email
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as server:
        server.login(sender_email, password)

        textMsg = """{}, your password has been successfully changed \n\n""".format(
            username)

        part1 = MIMEText(textMsg, 'plain')

        msg.attach(part1)

        server.sendmail(sender_email, receiver, msg.as_string())

    return 'changed'


def auth(db, cursor, username):
    str = """select email,otp from usertb where username=%s"""
    cursor.execute(str, (username,))
    email = cursor.fetchall()

    return email
