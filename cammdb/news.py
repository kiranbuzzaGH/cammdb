from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from werkzeug.exceptions import abort

from cammdb.auth import login_required
from cammdb.db import get_db

bp = Blueprint("news", __name__)


@bp.route("/")
def index():
    db = get_db()
    posts = db.execute(
        "SELECT posts.id, title, body, created, author_id, name FROM posts JOIN users ON posts.author_id = users.id ORDER BY created DESC"
    ).fetchall()
    return render_template("news/index.html", posts=posts)


@bp.route("/post/create", methods=("GET", "POST"))
@login_required
def create_post():
    if request.method == "POST":
        title = request.form["title"]
        body = request.form["body"]
        error = None

        if not title:
            error = "Title is required."

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                "INSERT INTO posts (title, body, author_id)"
                "VALUES (?, ?, ?)",
                (title, body, g.user["id"])
            )
            db.commit()
            return redirect(url_for("news.index"))

        return render_template("news/create_post.html")


def get_post(id, check_author=True):
    post = get_db().execute(
        "SELECT posts.id, title, body, created, author_id, name"
        "FROM posts JOIN users ON posts.author_id = users.id"
        "WHERE posts.id = ?",
        (id,)
    ).fetchone()

    if post is None:
        abort(404, f"Post id {id} doesn't exist.")

    if check_author and post["author_id"] != g.user["id"]:
        abort(403)

    return post


@bp.route("/post/<int:id>/update", methods=("GET", "POST"))
@login_required
def update_post(id):
    post = get_post(id)

    if request.method == "POST":
        title = request.form["title"]
        body = request.form["body"]
        error = None

        if not title:
            error = "Title is required."

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                "UPDATE posts SET title = ?, body = ?"
                "WHERE id = ?",
                (title, body, id)
            )
            db.commit()
            return redirect(url_for("news.index"))

    return render_template("news/update_post.html", post=post)


@bp.route("/post/<int:id>/delete", methods=("POST",))
@login_required
def delete_post(id):
    get_post(id)
    db = get_db()
    db.execute("DELETE FROM posts WHERE id = ?", (id,))
    db.commit()
    return redirect(url_for("news.index"))
