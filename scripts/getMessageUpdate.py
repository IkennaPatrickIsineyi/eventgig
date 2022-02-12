#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


def retrivChats(db, cursor, username, sender, chatid):
    str = """select time, date, sender, receiver, message, seen, chatid from chattb where
     (sender=%s and receiver=%s) and chatid > %s """
    cursor.execute(str, (sender, username, chatid))
    chats = cursor.fetchall()

    return chats


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
