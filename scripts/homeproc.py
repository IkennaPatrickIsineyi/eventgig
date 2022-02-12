#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
import random
import datetime
import hashlib
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute

# get password and user classification of the user


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid = %s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1

# get pending, picked, delivered, and history of the user


def getOrders(cursor, username):
    str = """select time_created, event_type, event_date, budget, trnxid,client,planner from trnxtb where (planner=%s and status ='pending')
     or (client=%s and status='pending')"""
    cursor.execute(str, (username, username))
    pending = cursor.fetchall()

    str = """select event_date, event_type, budget, fee, trnxid,client,planner from trnxtb where (planner=%s and status ='scheduled')
     or (client=%s and status='scheduled')"""
    cursor.execute(str, (username, username))
    scheduled = cursor.fetchall()

    str = """select  time_completed, event_type, rating,comment, trnxid,client,planner from trnxtb where (planner=%s and status ='completed')
     or (client=%s and status='completed')"""
    cursor.execute(str, (username, username))
    completed = cursor.fetchall()

    return pending, scheduled, completed


def regular_stuff(db, cursor, username):
    # get user's account data
    str = """select email, phone,picture,verified,gender from usertb where username=%s"""
    cursor.execute(str, (username,))
    personal = cursor.fetchall()

    return personal


def profilePics(db, cursor, username, trnx):
    # get user's account data
    dps = []
    for trn in trnx:
        if username == trn[6]:
            user = trn[5]
        else:
            user = trn[6]
        str = """select picture from usertb where username=%s"""
        cursor.execute(str, (user,))
        picture = cursor.fetchall()
        dps.append(picture)

    return dps
