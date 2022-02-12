#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def retrivPersonal(db, cursor, username):
    str = """select phone,email,planner, picture,terms,fee from usertb where username=%s"""
    cursor.execute(str, (username,))
    personal = cursor.fetchall()

    return personal


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
