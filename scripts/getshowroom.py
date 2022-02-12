#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute

def retrivShowroom(db, cursor, username):
    str = """select showroomid,photo from showroomtb where username=%s"""
    cursor.execute(str, (username,))
    showroom = cursor.fetchall()

    return showroom


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
