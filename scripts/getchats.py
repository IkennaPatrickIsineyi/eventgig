#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def retrivChats(db, cursor, username, receiver, nextchatid):
    if nextchatid == 0:
        str = """select time, date, sender, receiver, message, seen, chatid from chattb where
         ((sender=%s and receiver=%s) or (sender=%s and receiver=%s)) order by chatid desc
         limit 20"""
        cursor.execute(str, (username, receiver, receiver, username))
    else:
        str = """select time, date, sender, receiver, message, seen, chatid from chattb where
         ((sender=%s and receiver=%s) or (sender=%s and receiver=%s)) and chatid < %s
         order by chatid desc limit 20"""
        cursor.execute(
            str, (username, receiver, receiver, username, nextchatid))
    chats = cursor.fetchall()

    return chats


def retrivProfile(db, cursor, receiver):
    str = """select username,picture,last_seen from usertb where username=%s"""
    cursor.execute(str, (receiver,))
    userProfile = cursor.fetchall()

    return userProfile


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
