#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

from datetime import datetime
#import datetime as dtime
#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def updateLastSeen(db, cursor, username):
    x = datetime.now()
    nowtime = x.strftime('%I')+':'+x.strftime('%M') + \
        ':'+x.strftime('%S')+' '+x.strftime('%p')
    nowdate = x.strftime('%d')+'-'+x.strftime('%b')+'-'+x.strftime('%Y')
    curr_time = nowdate+'  '+nowtime

    str = """update usertb set last_seen=%s where username=%s"""
    cursor.execute(str, (curr_time, username))
    db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
