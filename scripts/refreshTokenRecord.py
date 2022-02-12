from pyfcm import FCMNotification


def refresh_tokens_record(db, cursor):
    str = """delete from logintb where deviceToken is null"""
    cursor.execute(str)
    db.commit()
    str = """select deviceToken, sessionid from logintb"""
    cursor.execute(str)
    tokens = cursor.fetchall()

    if len(tokens) > 0:
        deadList = []
        allList = []

        return tokens, deadList

    else:
        return 'empty', 'empty'
