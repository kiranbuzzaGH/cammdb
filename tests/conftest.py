import os
import tempfile

import pytest
from cammdb import create_app
from cammdb.db import get_db, init_db
from instance.config import TestingConfig

with open(os.path.join(os.path.dirname(__file__), "data.sql"), "rb") as f:
    _data_sql = f.read().decode("utf8")


@pytest.fixture
def app():

    db_fd, db_path = tempfile.mkstemp()
    os.close(db_fd) # Don't need file descriptor so close as early as possible

    class LocalTestingConfig(TestingConfig):
        DATABASE = str(db_path)

    app = create_app(LocalTestingConfig)

    with app.app_context():
        init_db()
        get_db().executescript(_data_sql)

    yield app

    os.unlink(db_path)


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()


class AuthActions(object):
    def __init__(self,  client):
        self._client = client

    def login(self, name="test", password="test"):
        return self._client.post(
            "/auth/login",
            data={"name": name, "password": password}
        )

    def logout(self):
        return self._client.get("/auth/logout")


@pytest.fixture
def auth(client):
    return AuthActions(client)
