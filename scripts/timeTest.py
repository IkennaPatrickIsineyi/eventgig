from datetime import datetime, timedelta
from time import sleep

""" x = datetime.now()
nowtime = x.strftime('%I')+':' + \
    x.strftime('%M')+' '+x.strftime('%p') """

t = datetime.now()
sleep(5)
#k = str(datetime.now)-t

print((datetime.now() - t).total_seconds())
