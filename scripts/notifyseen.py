#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


#import mysql.connector as conn

# extract data from submited form that has process.cgi as its action attribute


def updateNotify(db, cursor, notifyid):

    strg = """update notifytb set seen=%s where notifyid=%s"""

    cursor.execute(strg, (1, notifyid))
    db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
