#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe


#import mysql.connector as conn

# creates new order and returns all the qualified and available couriers for the order


def retrivAvailable(db, cursor, username):
    str = """select username,picture,rating,fee,date_created from usertb where planner=1 and username != %s"""
    cursor.execute(str, (username,))
    available = cursor.fetchall()

    if len(available) > 0:
        hit = 'yes'
        showroom = []
        for planner in available:
            str = """select showroomid,photo from showroomtb where username=%s"""
            cursor.execute(str, (planner[0],))
            showroom1 = cursor.fetchall()
            showroom.append(showroom1)

    else:
        hit = 'no'
        showroom = 'empty'
    return available, showroom, hit


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
