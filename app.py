from flask import Flask

app = Flask(__name__)


@app.route("/")
def homepage():
    return "Homepage in production"

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

@app.route("/register")
def register():
    return "Register in production"

@app.route("/login")
def login():
    return "Login in production"

@app.route("/user/<username>")
def user_profile(username):
    """Show the user profile for given user"""
    return f"User {escape(username)}"

@app.route("/about")
def about():
    return "About page in production"
