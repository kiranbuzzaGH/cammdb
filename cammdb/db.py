"""Connects the application to the SQLite database"""

import sqlite3
from datetime import datetime

import click
from flask import current_app, g


def get_db():
    """
    Return the database connection, or makes and stores the connection in the
    case that no connection has been made.

    Return Value
    g.db -- the database connection
    """
    if "db" not in g:
        g.db = sqlite3.connect(
            current_app.config["DATABASE"],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

    return g.db


def close_db():
    """
    Checks if a connection was created and, if relevant, closes it.
    """
    db = g.pop("db", None)

    if db is not None:
        db.close()


def init_db():
    """
    Clear the existing data and create new tables.
    """
    db = get_db()

    with current_app.open_resource("schema.sql") as f:
        db.executescript(f.read().decode("utf8"))


@click.command("init-db")
def init_db_command():
    """
    Allows user to call the init_db function from the command line.
    """
    init_db()
    click.echo("Initialized the database.")


sqlite3.register_converter(
    "timestamp", lambda v: datetime.fromisoformat(v.decode())
)


def init_app(app):
    """
    Registers the close_db and init_db_command functions with the application.

    Arguments
    app -- the application defined within the factory function
    """
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
