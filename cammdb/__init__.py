import os

from dotenv import load_dotenv
from flask import Flask
from flask_seasurf import SeaSurf
from flask_talisman import Talisman

from . import db
from . import auth
from . import news
from . import users
from instance.config import Config



load_dotenv()

def create_app(test_config=None):
    # Create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    # Prevent cross site request forgery
    # Docs: https://flask-seasurf.readthedocs.io/en/latest/
    csrf = SeaSurf(app)

    # Wrap app with a Talisman to protect against security issues - currently default (most secure)
    # settings
    # Docs: https://github.com/GoogleCloudPlatform/flask-talisman
    Talisman(app)

    app.config.from_mapping(DATABASE=os.path.join(app.instance_path, "cammdb.sqlite"),)

    # Load the default config
    app.config.from_object(Config)

    # Override with test config if provided
    if test_config:
        app.config.from_mapping(test_config)

    # Ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass


    db.init_app(app)

    app.register_blueprint(auth.bp)

    app.register_blueprint(news.bp)
    app.add_url_rule("/", endpoint="index")

    app.register_blueprint(users.bp)

    return app
