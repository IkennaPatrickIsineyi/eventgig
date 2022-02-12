
from logging import debug, log
from flask import Flask, request
import json
from codecs import decode
import smtplib
import ssl
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from json.decoder import JSONDecodeError, JSONDecoder
from typing import List
import random
from datetime import datetime
import hashlib
from flask.helpers import url_for
from flask.wrappers import Response


import psycopg2 as conn
from werkzeug.exceptions import abort
from werkzeug.utils import secure_filename


import loginproc
import accptjobproc
import cancproc
import changedp
import chathistory
import deletepic
import detailproc
import finish
import genOtp
import getchats
import getsettings
import getshowroom
import hireproc
import homeproc
import logout
import ordproc
import passwordotp
import plannerdetails
import regproc
import rejjobproc
import resetpassword
import savesettings
import sendchat
import deletechats
import getOnlineStatus
import updateLastSeen
import getMessageUpdate

import getupdate
import notifyseen

import uploadpic
import verifyotp

import notifyuser
import notifyusers
import notifyusersFBA
import saveSession
import userdetails

import getunseen
import getunclicked
import seenNotification
import clickedNotification

import refreshTokenRecord

application = Flask(__name__, static_url_path='/static')
path = os.getcwd()
application.config['UPLOAD_FOLDER'] = os.path.join(path, 'mysite/static')

x = datetime.now()
nowtime = x.strftime('%I')+':' + \
    x.strftime('%M')+' '+x.strftime('%p')
nowdate = x.strftime('%d')+'-' + \
    x.strftime('%b')+'-'+x.strftime('%Y')
time_created = nowdate+'  '+nowtime


def connectDBServ():
    DATABASE_URL = os.environ['DATABASE_URL']
    db = conn.connect(DATABASE_URL, sslmode='require')

    cursor = db.cursor()
    #allTokens, deadTokens=refreshTokenRecord.refresh_tokens_record(db, cursor)
    return db, cursor

# get password and user classification of the user


def updateNotify(db, cursor, time, date, receiver, body, title, trnxid):
    if trnxid == None:
        strg = """insert into notifytb (time,date,receiver,body,seen,title) values (%s,%s,%s,%s,%s,%s)"""
        cursor.execute(strg, (time, date, receiver, body, 0, title))
        db.commit()
    else:
        strg = """insert into notifytb (time,date,receiver,body,seen,title, trnxid) values (%s,%s,%s,%s,%s,%s,%s)"""
        cursor.execute(strg, (time, date, receiver, body, 0, title, trnxid))
        db.commit()


@application.route('/', methods=['POST', 'GET'])
def index():
    db, cursor = connectDBServ()
    updateNotify(db, cursor, nowtime, nowdate, "ik", "body", "title", None)
    cursor.close()
    db.close()
    return 'Welcome to EventGig'


if __name__ == '__main__':
    application.run(host='0.0.0.0', port=80, debug=True)
