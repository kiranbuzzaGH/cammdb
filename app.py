from flask import Flask
from flask import render_template
from flask import request
from models import engine
from sqlalchemy import text

app = Flask(__name__)


@app.route("/")
def homepage():
    return render_template("index.html")

@app.route("/gigs")
def gig_list():
    return "Gig list in production"

@app.route("/artists")
def artists():
    return "Artists in production"

@app.route("/profiles")
def profiles():
    return "Profiles in production"

@app.route("/opportunities")
def opportunities():
    return "Opportunities in production"

@app.route("/calendar")
def calendar():
    return "Calendar in production"

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        return "Register in production"
    else:
        return "Register in production"

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        return "Login in production"
    else:
        return "Login in production"

@app.route("/user/<username>")
def user_profile(username):
    """Show the user profile for given user"""
    return "User page in production"

@app.route("/about")
def about():
    """Render about page"""
    return "About page in production"
