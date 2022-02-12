from flask import Flask

application = Flask(__name__)


@application.route("/", methods=['POST', 'GET'])
def home_view():
    return "<h1>Welcome to the club, bitch</h1>"


if __name__ == "__main__":
    application.run()
