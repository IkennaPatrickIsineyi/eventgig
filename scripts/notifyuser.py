from pyfcm import FCMNotification


def send_notification(db, cursor, sessionid, title, body):
    str = """select deviceToken from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    token = cursor.fetchall()

    if len(token) == 1:
        return 'sent'
    else:
        return 'failed'
