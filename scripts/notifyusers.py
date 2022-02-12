from pyfcm import FCMNotification


def send_notification(db, cursor, username, title, body):
    str = """select deviceToken from logintb where username=%s and deviceToken is not null"""
    cursor.execute(str, (username,))
    tokens = cursor.fetchall()

    if len(tokens) > 0:
        return []
    else:
        return 'empty'
