import requests
import json

usern = 'kikk'
passwd = 'ioio'
email = 'emialls'
gender = 'male'
sessID = 'sedsdsddssdsdsdsfddsd'

""" url = "http://ikp120.pythonanywhere.com/adduser"
param = {'username': usern, 'password': passwd, 'email': email,
         'gender': gender, 'sessionid': sessID, 'deviceID': 'unknown', 'deviceToken': 'unknown'}

pyResp = requests.post(url, data=param)
js = json.loads(pyResp.text)
print(js['login'])
 """

url = "http://ikp120.pythonanywhere.com/loginuser"
param = {'username': usern, 'password': passwd, 'sessionid': sessID,
         'deviceid': 'unknown', 'deviceToken': 'unknown'}

pyResp = requests.post(url, data=param)
js = json.loads(pyResp.text)
print(js['login'])
