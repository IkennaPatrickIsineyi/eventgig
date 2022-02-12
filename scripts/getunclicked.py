#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def retrivNotifications(db, cursor, username):
    # user has not clicked the notification
    str = """select notifyid,time,date, trnxid,body,title,clicked from 
    notifytb where receiver=%s order by notifyid desc"""
    cursor.execute(str, (username,))
    notifications = cursor.fetchall()

    if len(notifications) > 0:
        strg = """update notifytb set seen=%s where receiver=%s and seen=%s and notifyid<=%s"""
        cursor.execute(strg, (1, username, 0, notifications[0][0]))
        db.commit()

        return notifications
    else:
        return []


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
