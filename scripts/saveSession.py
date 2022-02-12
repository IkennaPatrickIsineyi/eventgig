def insert_message(db, cursor, login_time, sessionid, username, deviceid, deviceToken):
    strg = """insert into logintb (username,login_time,sessionid, deviceid, deviceToken) values (%s,%s,%s,%s,%s)"""
    cursor.execute(strg, (username, login_time,
                   sessionid, deviceid, deviceToken))
    db.commit()
