from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)

from cammdb.auth import login_required
from cammdb.db import get_db

bp = Blueprint("users", __name__, url_prefix="/users")


@bp.route("/")
def profile():
    db = get_db()
    profiles = db.execute(
        #TODO: introduce tags and join this query
        "SELECT name, id FROM users ORDER BY name"
    ).fetchall()
    return render_template("users/profiles.html", profiles=profiles)


def get_profile(id):
    db = get_db()
    profile = db.execute(
        "SELECT name, description, email, id FROM users WHERE id = ?",
        (id,)
    ).fetchone()

    if profile is None:
        abort(404, f"Profile doesn't exist.")

    return profile


@bp.route("/profile/<int:id>")
def display_profile(id):
    profile = get_profile(id)

    return render_template("users/profile_template.html", profile=profile)


@bp.route("/profile/update", methods=("GET", "POST"))
@login_required
def update_profile():
    if request.method == "POST":
        name = request.form["name"]
        description = request.form["description"]
        email = request.form["email"]
        error = None

        if not name:
            error = "Name is required."

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                "UPDATE users SET name = ?, description = ?, email = ?"
                "WHERE id = ?",
                (name, description, email, g.user["id"])
            )
            db.commit()
            return redirect(url_for("users.profiles"))

    return render_template("users/update_profile.html", user=g.user)





