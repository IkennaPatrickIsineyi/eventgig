#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def retrivDetails(db, cursor, trnxid):
    try:
        str = """select client,planner,time_created,event_date,street,event_type,budget,
        status,fee,note,trnxid,rating,comment,city,state,country from trnxtb where trnxID=%s"""
        cursor.execute(str, (trnxid,))
        details = cursor.fetchall()
        return details
    except:
        return "empty"


def retrivPersonal(db, cursor, partner):
    str = """select phone,email,gender from usertb where username=%s"""
    cursor.execute(str, (partner,))
    personal = cursor.fetchall()

    return personal


def auth(db, cursor, sessionid, trnxid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    str = """select client,planner from trnxtb where trnxid=%s"""
    cursor.execute(str, (trnxid,))
    usersInvolved = cursor.fetchall()

    return username1, usersInvolved
