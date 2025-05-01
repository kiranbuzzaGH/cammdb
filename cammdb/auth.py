"""This deals with all the authentication, (that is login, register and OAuth) of the app."""

import requests

from flask import (
    abort, Blueprint, current_app, flash, g, redirect, render_template, request, session, url_for
)
from functools import wraps
from secrets import token_urlsafe
from urllib import parse
from werkzeug.security import check_password_hash, generate_password_hash


from cammdb.db import get_db

bp = Blueprint("auth", __name__, url_prefix="/auth")


@bp.route("/register", methods=("GET", "POST"))
def register():
    if request.method == "POST":
        name = request.form["name"]
        password = request.form["password"]
        description = request.form["description"]
        email = request.form["email"]
        db = get_db()
        error = None

        if not name:
            error = "Name is required."
        elif not password:
            error = "Password is required."

        if error is None:
            try:
                db.execute(
                    "INSERT INTO users (name, password, description, email) VALUES (?, ?, ?, ?)",
                    (name, generate_password_hash(password), description, email),
                )
                db.commit()
            except db.IntegrityError:
                error = f"User {name} is already registered."
            else:
                # Sign user in
                user = db.execute(
                    "SELECT * FROM users WHERE name = ?", (name,)
                ).fetchone()

                session.clear()
                session["user_id"] = user["id"]

                return redirect(url_for("index"))

        flash(error)

    return render_template("auth/register.html")


@bp.route("/login", methods=("GET", "POST"))
def login():
    if request.method == "POST":
        name = request.form["name"]
        password = request.form["password"]
        db = get_db()
        error = None
        user = db.execute(
            "SELECT * FROM users WHERE name = ?", (name,)
        ).fetchone()

        if user is None:
            error = "Incorrect username."
        elif not check_password_hash(user["password"], password):
            error = "Incorrect password."

        if error is None:
            session.clear()
            session["user_id"] = user["id"]
            return redirect(url_for("index"))

        flash(error)

    return render_template("auth/login.html")


@bp.before_app_request
def load_logged_in_user():
    user_id = session.get("user_id")

    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            "SELECT * FROM users WHERE id = ?", (user_id,)
        ).fetchone()


@bp.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))


def login_required(view):
    @wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for("auth.login"))

        return view(**kwargs)

    return wrapped_view


@bp.route("/password-reset", methods=("GET", "POST"))
@login_required
def password_reset():
    """Change user password"""
    if request.method == "POST":
        old_password = request.form["old_password"]
        new_password = request.form["new_password"]
        db = get_db()
        error = None

        if not g.user["password"]:
            error = "You have no password set."
        if not check_password_hash(g.user["password"], old_password):
            error = "Incorrect password."
        if not new_password:
            error = "New password is required"

        if error is not None:
            flash(error)
        else:
            db.execute(
                "UPDATE users SET password = ?"
                "WHERE id = ?",
                (generate_password_hash(new_password), g.user["id"])
            )
            db.commit()
            return redirect(url_for("index"))

    return render_template("auth/password_reset.html")


@bp.route("/authorize/<provider>")
def oauth2_authorize(provider):
    if session.get("user_id") is not None:
        return redirect(url_for("index"))

    provider_data = current_app.config["OAUTH2_PROVIDERS"].get(provider)
    if provider_data is None:
        abort(404)

    session["oauth2_state"] = token_urlsafe(32)

    # OAuth query
    # See for how to build: https://developers.google.com/identity/protocols/oauth2/web-server
    query_string = parse.urlencode({
        "client_id": provider_data["client_id"],
        "redirect_uri": url_for("auth.oauth2_callback", provider=provider, _external=True),
        "response_type": "code",
        "scope": " ".join(provider_data["scope"]),
        "state": session["oauth2_state"],
        "include_granted_scopes": "true",
    })

    return redirect(provider_data["auth_uri"] + "?" + query_string)


@bp.route("/callback/<provider>")
def oauth2_callback(provider):
    if not current_user.is_anonymous:
        return redirect(url_for("index"))

    provider_data = current_app.config["OAUTH2_PROVIDERS"].get(provider)
    if provider_data is None:
        abort(404)

    if "error" in request.args:
        for key, value in request.args.items():
            if key.startswith("error"):
                flash(f"{key}: {value}")
        return redirect(url_for("index"))

    # Only want to proceed if the session state parameter is the same as the one in the request
    if request.args["state"] != session.get("oauth2_state"):
        abort(401)

    # Only proceed if response URL contains an authorization code
    if "code" not in request.args:
        abort(401)


    data = {
        "client_id": provider_data["client_id"],
        "client_secret": provider_data["client_secret"],
        "code": request.args["code"],
        "grant_type": "authorization_code",
        "redirect_uri": url_for("auth.oauth2_callback", provider=provider, _external=True),
    }

    # Exchange auth code for an access token (more secure than getting the
    # access token directly over http)
    response = requests.post(provider_data["token_url"], data=data,
                             headers={"Accept": "application/json"})
    if response.status_code != 200:
        abort(401)

    oauth2_token = response.json().get("access_token")
    if not oauth2_token:
        abort(401)

    # Get the name and email in json format
    response = request.get(provider_data["userinfo"]["url"], headers={
        "Authorization": "Bearer" + oauth2_token,
        "Accept": "application/json",
    })
    if response.status_code != 200:
        abort(401)

    email = provider_data["userinfo"]["email"](response.json())
    name = provider_data["userinfo"]["name"](response.json())

    db = get_db()
    user = db.execute(
        "SELECT * FROM users WHERE name = ?", (name,)
    ).fetchone()
    # Register user if they don't already exist
    if user is None:
        db.execute(
            "INSERT INTO users (name, email) VALUES (?, ?)",
            (name, email),
        )
        db.commit()

        user = db.execute(
            "SELECT * FROM users WHERE name = ?", (name,)
        ).fetchone()

    session.clear()
    session["user_id"] = user["id"]

    return redirect(url_for("index"))
