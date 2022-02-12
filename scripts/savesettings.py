#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
import datetime
#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def insert_order(db, cursor, username, email, phone, profilePic, terms, planner, fee):

    strg = """update usertb set email=%s,phone=%s,picture=%s,terms=%s,
    planner=%s,fee=%s where username=%s"""

    cursor.execute(strg, (email, phone, profilePic,
                   terms, planner, fee, username))
    db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
