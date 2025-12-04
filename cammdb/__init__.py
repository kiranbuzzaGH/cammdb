import os

from dotenv import load_dotenv
from flask import Flask
from flask_seasurf import SeaSurf
from flask_talisman import Talisman

from . import db
from . import artists
from . import auth
from . import news
from . import users
from instance.config import DevelopmentConfig, TestingConfig, ProductionConfig



load_dotenv()

def create_app(config_override=None):
    # Create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    # Prevent cross site request forgery
    # Docs: https://flask-seasurf.readthedocs.io/en/latest/
    csrf = SeaSurf(app)

    # Wrap app with a Talisman to protect against security issues - currently default (most secure)
    # settings
    # Docs: https://github.com/GoogleCloudPlatform/flask-talisman
    Talisman(app)


    env = os.getenv("FLASK_ENV", "development")
    if env == "production":
        config_class = ProductionConfig
    else:
        config_class = DevelopmentConfig

    # Load the relevant config
    app.config.from_object(config_class)

    # Allows create_app to also accept dicts to supplement the config classes (used in testing)
    if isinstance(config_override, dict):
        app.config.update(config_override)
    elif config_override is not None:
        app.config.from_object(config_override)

    # Remember to connect to the correct environment database
    app.config.from_mapping(
        DATABASE=os.path.join(app.instance_path, config_class.DATABASE),
    )

    # Ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass


    db.init_app(app)

    app.register_blueprint(news.bp)
    app.add_url_rule("/", endpoint="index")

    app.register_blueprint(auth.bp)
    app.register_blueprint(users.bp)
    app.register_blueprint(artists.bp)


    return app
