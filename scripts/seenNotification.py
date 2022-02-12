#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def seen(db, cursor, username, notifyid):
    # notifyid is id of the most recent notification seen by user
    strg = """update notifytb set seen=%s where receiver=%s and seen=%s and notifyid<=%s"""
    cursor.execute(strg, (1, username, 0, notifyid))
    db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
