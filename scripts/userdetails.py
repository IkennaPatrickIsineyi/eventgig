#!C:\Users\hp\AppData\Local\Programs\Python\Python39\python.exe

#import mysql.connector as conn


# extract data from submited form that has process.cgi as its action attribute


def get_details(db, cursor, planner):
    # get successful deliveries,failed deliveries,cancelled deliveries
    str = """select rating,picture,birthday,wedding,house_warming,
    school_event,peagent,seminar,burial,others, date_created from usertb
     where username=%s"""

    cursor.execute(str, (planner,))
    details = cursor.fetchall()

    str = """select showroomid,photo from showroomtb where username=%s"""
    cursor.execute(str, (planner[0]))
    showroom = cursor.fetchall()

    # get successful deliveries,failed deliveries,cancelled deliveries
    str = """select client, time_completed,event_type, rating,comment from trnxtb
    where planner=%s and status='completed'"""
    cursor.execute(str, (planner,))
    reviews = cursor.fetchall()

    if len(reviews) > 0:
        client_pics = []
        for client in reviews:
            # get successful deliveries,failed deliveries,cancelled deliveries
            str = """select picture from usertb where username=%s"""
            cursor.execute(str, (client[0],))
            pic = cursor.fetchall()
            client_pics.append(pic[0][0])
    else:
        client_pics = []
    return details[0], reviews, client_pics, showroom


def auth(db, cursor, sessionid):
    str = """select username from logintb where sessionid=%s"""
    cursor.execute(str, (sessionid,))
    username1 = cursor.fetchall()

    return username1
