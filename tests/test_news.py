import pytest
from cammdb.db import get_db


def test_index(client, auth):
    response = client.get("/")
    assert b"Log In" in response.data
    assert b"Register" in response.data

    auth.login()
    response = client.get("/")
    assert b"Log Out" in response.data
    if b"by" in response.data:
        assert b"on" in response.data


@pytest.mark.parametrize("path", (
    "/post/create",
    "/post/1/update",
    "/post/1/delete",
))
def test_login_required(client, path):
    response = client.post(path)
    assert "Location" in response.headers
    assert response.headers["Location"] == "/auth/login"


def test_author_required(app, client, auth):
    # Change the post authir to another user
    with app.app_context():
        db = get_db()
        db.execute("UPDATE posts SET author_id = 2 WHERE id = 1")
        db.commit()

    auth.login()
    # Current user can't modify other user's post
    assert client.post("/post/1/update").status_code == 403
    assert client.post("/post/1/delete").status_code == 403
    # Current user doesn't see edit link
    assert b"href='/post/1/update'" not in client.get("/", follow_redirects=True).data


@pytest.mark.parametrize("path", (
    "/post/2/update",
    "/post/2/delete",
))
def test_exists_required(client, auth, path):
    auth.login()
    assert client.post(path).status_code == 404


def test_create(client, auth, app):
    auth.login()
    assert client.get("/post/create").status_code == 200
    client.post("/post/create", data={"title": "created", "body": ""})

    with app.app_context():
        db = get_db()
        count = db.execute("SELECT COUNT(id) FROM posts").fetchone()[0]
        assert count == 2


def test_update(client, auth, app):
    auth.login()
    assert client.get("/post/1/update").status_code == 200
    client.post("/post/1/update", data={"title": "updated", "body": ""})

    with app.app_context():
        db = get_db()
        post = db.execute("SELECT * FROM posts WHERE id = 1"). fetchone()
        assert post["title"] == "updated"


@pytest.mark.parametrize("path", (
    "/post/create",
    "/post/1/update",
))
def test_create_update_validate(client, auth, path):
    auth.login()
    response = client.post(path, data={"title": "", "body": ""})
    assert b"Title is required." in response.data


def test_delete(client, auth, app):
    auth.login()
    response = client.post("post/1/delete")
    assert response.headers["Location"] == "/"

    with app.app_context():
        db = get_db()
        post = db.execute("SELECT * FROM posts WHERE id = 1").fetchone()
        assert post is None
