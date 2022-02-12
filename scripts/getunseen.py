#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute

def retrivUnseen(db, cursor, username):
    # user has not seen the alert
    str = """select count(notifyid) from notifytb where receiver=%s and seen=%s"""
    cursor.execute(str, (username, 0))
    unseen = cursor.fetchall()

    return unseen[0][0]


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
