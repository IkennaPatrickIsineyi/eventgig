#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

import cgi
import json
from datetime import datetime
#import datetime as dtime
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def getOnlineStatus(db, cursor, users):
    onlineStatus = []
    last_seen = []
    for user in users:
        str = """select last_seen from usertb where username=%s"""
        cursor.execute(str, (user,))
        result = cursor.fetchall()
        last_seen.append(result[0][0])

        x = datetime.now()
        nowtime = x.strftime('%I')+':'+x.strftime('%M') + \
            ':'+x.strftime('%S')+' '+x.strftime('%p')
        nowdate = x.strftime('%d')+'-'+x.strftime('%b')+'-'+x.strftime('%Y')
        curr_time1 = nowdate+'  '+nowtime

        time_seen = datetime.strptime(result[0][0], "%d-%b-%Y  %I:%M:%S %p")
        curr_time = datetime.strptime(curr_time1, "%d-%b-%Y  %I:%M:%S %p")

        time_difference = curr_time-time_seen

        if (time_difference.seconds) > 10:
            onlineStatus.append(0)
        else:
            onlineStatus.append(1)

    return onlineStatus, last_seen


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
