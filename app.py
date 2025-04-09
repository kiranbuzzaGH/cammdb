# from flask import Flask, g, render_template, request, session
# from flask_session import Session
# from flask_talisman import Talisman
# from redis import Redis
# from sqlalchemy import text

# from helpers import login_required
# from models import engine

# app = Flask(__name__)

# # Configure session to use redis backend to store session -
# # https://flask-session.readthedocs.io/en/latest/usage.html#quickstart
# SESSION_TYPE = 'redis'
# SESSION_REDIS = Redis(host="localhost", port=6379)
# app.config.from_object(__name__)
# Session(app)

# # Wrap app with a Talisman to protect against security issues - currently
# # default (most secure) settings
# Talisman(app)

# # Control configuration values - https://flask.palletsprojects.com/en/stable/config/
# # In particular, app.config["SECRET_KEY"] has been assigned
# app.config.from_prefixed_env()


# @app.before_request
# def load_user():
#     g.user = None
#     user_id = session.get("user_id")
#     if user_id:
#         with engine.connect() as conn:
#             stmt = text("SELECT * FROM users where id = :user_id")
#             result = conn.execute(stmt, {"user_id": user_id}).first()
#             if result:
#                 g.user = dict(result._mapping)
#             else:
#                 # Clear invalid session
#                 session.pop("user_id", None)


# @app.route("/")
# def homepage():
#     return render_template("index.html")

# @app.route("/gigs")
# def gig_list():
#     return "Gig list in production"

# @app.route("/artists")
# def artists():
#     return "Artists in production"

# @app.route("/profiles")
# def profiles():
#     return "Profiles in production"

# @app.route("/opportunities")
# def opportunities():
#     return "Opportunities in production"

# @app.route("/calendar")
# def calendar():
#     return "Calendar in production"

# @app.route("/register", methods=["GET", "POST"])
# def register():
#     if request.method == "POST":
#         return "Register in production"
#     else:
#         return "Register in production"

# @app.route("/login", methods=["GET", "POST"])
# def login():
#     if request.method == "POST":
#         # TODO: login logic

#         # Regenerate session identifier when user logs in to prevent session fixation
#         app.session_interface.regenerate(session)
#         return "Login in production"
#     else:
#         return "Login in production"

# @app.route("/user/<username>")
# @login_required
# def user_profile(username):
#     """Show the user profile for given user"""
#     return "User page in production"

# @app.route("/about")
# def about():
#     """Render about page"""
#     return "About page in production"
