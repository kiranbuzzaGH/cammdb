from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)

from cammdb.auth import login_required
from cammdb.db import get_db

bp = Blueprint("users", __name__, url_prefix="/users")


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
                "WHERE id = ?"
                (title, description, email, g.user["id"])
            )
            db.commit()
            #TODO: finish making profile pages
            return redirect(url_for(""))

    #TODO: make relevant files
    return render_template("users/update_profile.html", user=g.user)





