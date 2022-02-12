#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def retrivNotification(db, cursor, username):
    str = """select notifyid,time,date, trnxid,receiver,body,seen,
    title from notifytb where receiver=%s and seen=%s"""
    cursor.execute(str, (username, 0))
    notification = cursor.fetchall()

    return notification


def updateNotify(db, cursor, notification):
    for item in notification:
        notifyid = item[0]

        strg = """update notifytb set seen=%s where notifyid=%s"""
        cursor.execute(strg, (1, notifyid))
        db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
