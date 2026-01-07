import os
import pytest
from cammdb import create_app
from instance.config import TestingConfig



@pytest.fixture
def secure_app():

    class SecurityTestingConfig(TestingConfig):
        TALISMAN_ENABLED = True

    app = create_app(SecurityTestingConfig)

    yield app


@pytest.fixture
def secure_client(secure_app):
    return secure_app.test_client()


def test_http_to_https_redirect(secure_client):
    """
    Tests that Talisman correctly forces the url from http to https
    """
    # Act
    # Explicitly make follow redirects false
    response = secure_client.get("auth/register/", follow_redirects=False)

    # Assert
    assert response.status_code == 302
    assert "Location" in response.headers
    assert response.headers["Location"].startswith("https://")

