#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
from typing import Set
from .import getOnlineStatus
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute
def getName():
    formData = cgi.FieldStorage()
    sessionid = formData.getvalue('sessionid')
    username = formData.getvalue('username')
    return sessionid, username


def retrivProfiles(db, cursor, username):
    print('id:1')
    str = """select sender, receiver from chattb where (sender=%s or receiver=%s) """
    cursor.execute(str, (username, username))
    print('id:2')
    chats = cursor.fetchall()

    print('id:3')
    users = set()
    profiles = []
    onlineStatus = []
    last_messages = []
    last_seen = []

    print('id:4')

    for item in chats:
        users.add(item[0])
        users.add(item[1])
    print('id:5')

    if len(users) != 0:
        users.remove(username)
        onlineStatus, last_seen = getOnlineStatus.getOnlineStatus(
            db, cursor, users)
    print('id:6')

    for user in users:
        print('id:7')
        str = """select username,picture from usertb where username=%s"""
        cursor.execute(str, (user,))
        print('id:8')
        userProfile = cursor.fetchall()

        profiles.append(userProfile[0])
        print('id:9')

        str = """select sender, receiver,time,date,message from chattb where (sender=%s
        and receiver=%s) or (sender=%s and receiver=%s) order by chatid desc limit 1 """
        cursor.execute(str, (user, username, username, user))
        print('id:10')
        last_msg = cursor.fetchall()
        last_messages.append(last_msg[0])

    print('id:11')
    return profiles, onlineStatus, last_seen, last_messages


def auth(db, cursor, sessionid):
    print('id:12')
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    print('id:13')
    username1 = cursor.fetchall()

    print('id:14')
    return username1
