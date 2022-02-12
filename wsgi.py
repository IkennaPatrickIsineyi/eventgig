from gevent.pywsgi import WSGIServer
from job.newTest import application
import os

if __name__ == '__main__':
    print('new Connection created...')
    PORT = os.environ['PORT']
    servr = WSGIServer(("", PORT), application=application)
    servr.serve_forever()
    # socket.run(application, host="127.0.0.1", port="3535", debug=True)

    # application.run(debug=True)
