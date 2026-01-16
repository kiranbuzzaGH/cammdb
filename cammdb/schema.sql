-- Drop tables in reverse order to prevent any issues with foreign keys and already dropped tables
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS opportunity_tag_map;
DROP TABLE IF EXISTS opportunity_tags;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS event_tag_map;
DROP TABLE IF EXISTS event_tags;
DROP TABLE IF EXISTS event_artists;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS artist_members;
DROP TABLE IF EXISTS artist_tag_map;
DROP TABLE IF EXISTS artist_tags;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS user_instruments;
DROP TABLE IF EXISTS instruments;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;


CREATE TABLE users(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        bio             TEXT,
        created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        display_name    TEXT,
        email           TEXT,
        is_admin        BOOLEAN DEFAULT 0, -- Note, BOOLEAN casts onto NUMERIC
        name            TEXT NOT NULL,
        password        TEXT  -- Note, stored as hash
);
CREATE TABLE roles(
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT UNIQUE NOT NULL   -- Eg musician, photographer etc
);
CREATE TABLE user_roles(
        role_id         INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        FOREIGN KEY(role_id) REFERENCES roles(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE instruments(
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT UNIQUE NOT NULL
);
CREATE TABLE user_instruments(
        instrument_id   INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,       -- Only if role musician
        FOREIGN KEY(instrument_id) REFERENCES instruments(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE artists(
        id                      INTEGER PRIMARY KEY AUTOINCREMENT,
        bio                     TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_id                INTEGER NOT NULL, -- When querying, make default the creator
        name                    TEXT NOT NULL,
        FOREIGN KEY(owner_id) REFERENCES users(id)
);
CREATE TABLE artist_tags(
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT UNIQUE NOT NULL   -- Eg genre, type (originals/covers/acoustic), status
);
CREATE TABLE artist_tag_map(
        artist_id       INTEGER NOT NULL,
        tag_id          INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(tag_id) REFERENCES artist_tags(id)
);
CREATE TABLE artist_members(
        artist_id       INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE venues(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        address         TEXT,
        name            TEXT NOT NULL,
        website         TEXT
);
CREATE TABLE events(
        id                      INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description             TEXT,
        end_datetime            DATETIME DEFAULT NULL, -- Remember to compute the default endtime (eg midnight the next day) if none when querying
        name                    TEXT DEFAULT NULL,     -- Remember to make this the top billing artist if null when querying
        organiser_id            INTEGER NOT NULL,      -- When querying, make default current user
        start_datetime          DATETIME NOT NULL,
        venue_id                INTEGER,
        FOREIGN KEY(organiser_id) REFERENCES users(id),
        FOREIGN KEY(venue_id) REFERENCES venues(id)
);
CREATE TABLE event_artists(
        artist_id       INTEGER NOT NULL,
        event_id        INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(event_id) REFERENCES events(id)
);
CREATE TABLE event_tags(
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT UNIQUE NOT NULL   -- Eg jam/open mic, genre etc
);
CREATE TABLE event_tag_map(
        event_id       INTEGER NOT NULL,
        tag_id          INTEGER NOT NULL,
        FOREIGN KEY(event_id) REFERENCES events(id),
        FOREIGN KEY(tag_id) REFERENCES event_tags(id)
);
CREATE TABLE opportunities(
        id                      INTEGER PRIMARY KEY AUTOINCREMENT,
        artist_id               INTEGER, -- optional
        body                    TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_id                INTEGER NOT NULL,
        expires_at              DATETIME,
        title                   TEXT NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(owner_id) REFERENCES users(id)
);
CREATE TABLE opportunity_tags(
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        name    TEXT UNIQUE NOT NULL   -- Eg permanent/temp, audition, looking for work etc
);
CREATE TABLE opportunity_tag_map(
        instrument_id           INTEGER,                -- eg guitarist, trumpeter...
        opportunity_id          INTEGER NOT NULL,
        opportunity_tag_id      INTEGER,                -- eg permanent/temp, audition, looking...
        roles_id                INTEGER,                -- eg musician, photographer...
        FOREIGN KEY(instrument_id) REFERENCES instruments(id),
        FOREIGN KEY(opportunity_id) REFERENCES opportunities(id),
        FOREIGN KEY(opportunity_tag_id) REFERENCES opportunity_tags(id),
        FOREIGN KEY(roles_id) REFERENCES roles(id)
);
CREATE TABLE posts (
        id                      INTEGER PRIMARY KEY AUTOINCREMENT,
        author_id               INTEGER NOT NULL,
        body                    TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title                   TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES users (id)
);
