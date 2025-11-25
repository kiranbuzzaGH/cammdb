from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)

from cammdb.auth import login_required
from cammdb.db import get_db

bp = Blueprint("artists", __name__, url_prefix="/artists")


@bp.route("/")
def profiles():
    db = get_db()
    artists = db.execute(
        #TODO: introduce tags and join this query
        "SELECT name, id FROM artists ORDER BY name"
    ).fetchall()
    return render_template("artists/artists.html", artists=artists)


def get_artist(id, check_author=False):
    db = get_db()
    artist = db.execute(
        "SELECT name, description, id FROM artists WHERE id = ?",
        (id,)
    ).fetchone()

    if artist is None:
        abort(404, f"Profile doesn't exist.")

    if check_author and artist["id"] != g.user["id"]:
        abort(403)

    return artist


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


@bp.route("/profile/<int:id>/delete", methods=("POST",))
@login_required
def delete_profile(id):
    get_profile(id, True)
    db = get_db()
    db.execute("DELETE FROM users WHERE id = ?", (id,))
    db.commit()
    return redirect(url_for("users.profiles"))




