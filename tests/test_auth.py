import pytest
from flask import g, session
from cammdb.db import get_db


def test_register(client, app):
    response = client.get("/auth/register")
    assert response.status_code == 200

    response = client.post(
        "/auth/register", data={"name": "a", "password": "a",}
    )
    assert response.status_code == 302
    assert response.headers["Location"] == "/"

    with app.app_context():
        assert get_db().execute(
            "SELECT * FROM users WHERE name = 'a'",
        ).fetchone() is not None


@pytest.mark.parametrize(("name", "password", "message"), (
    ("", "", b"Name is required."),
    ("a", "", b"Password is required."),
    ("test", "test", b"already registered"),
))
def test_register_validate_input(client, name, password, message):
    response = client.post(
        "/auth/register",
        data={"name": name, "password": password},
        follow_redirects=True
    )
    assert message in response.data


def test_login(client, auth):
    assert client.get("/auth/login").status_code == 200
    response = auth.login()
    assert response.headers["Location"] == "/"

    with client:
        client.get("/")
        assert session["user_id"] == 1
        assert g.user["name"] == "test"


@pytest.mark.parametrize(("name", "password", "message"), (
    ("a", "test", b"Incorrect username."),
    ("test", "a", b"Incorrect password."),
))
def test_login_validate_input(auth, name, password, message):
    response = auth.login(name, password)
    assert message in response.data


def test_logout(client, auth):
    auth.login()

    with client:
        auth.logout()
        assert "user_id" not in session
