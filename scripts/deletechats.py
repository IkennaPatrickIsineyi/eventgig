import json


def deleteChats(db, cursor, chatids, username):
    for chat in json.loads(chatids):
        strg = """delete from chattb where chatid=%s and sender=%s"""
        cursor.execute(strg, (int(chat), username))
        db.commit()


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
