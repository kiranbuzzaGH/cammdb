-- To be safe, always explicitly enable foreign keys
PRAGMA foreign_keys = ON;


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
        id              INTEGER PRIMARY KEY,
        bio             TEXT,
        created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        display_name    TEXT,
        email           TEXT,
        is_admin        INTEGER NOT NULL DEFAULT 0 CHECK (is_admin IN (0,1)),
        name            TEXT NOT NULL,
        password        TEXT  -- Note, stored as hash
);
CREATE TABLE roles(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg musician, photographer etc
);
CREATE TABLE user_roles(
        role_id         INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        PRIMARY KEY(role_id, user_id) NOT NULL,
        FOREIGN KEY(role_id) REFERENCES roles(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE INDEX user_roles_index_role_id ON user_roles(role_id);
CREATE INDEX user_roles_index_user_id ON user_roles(user_id);
CREATE TABLE instruments(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL
);
CREATE TABLE user_instruments(
        instrument_id   INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,       -- Only if role musician
        PRIMARY KEY(instrument_id, user_id) NOT NULL,
        FOREIGN KEY(instrument_id) REFERENCES instruments(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE INDEX user_instruments_index_instrument_id ON user_instruments(instrument_id);
CREATE INDEX user_instruments_index_user_id ON user_instruments(user_id);
CREATE TABLE artists(
        id                      INTEGER PRIMARY KEY,
        bio                     TEXT,
        created_at              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_id                INTEGER NOT NULL, -- When querying, make default the creator
        name                    TEXT NOT NULL,
        FOREIGN KEY(owner_id) REFERENCES users(id)
);
CREATE INDEX artists_index_owner_id ON artists(owner_id);
CREATE TABLE artist_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg genre, type (originals/covers/acoustic), status
);
CREATE TABLE artist_tag_map(
        artist_id       INTEGER NOT NULL,
        tag_id          INTEGER NOT NULL,
        PRIMARY KEY(artist_id, tag_id) NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(tag_id) REFERENCES artist_tags(id)
);
CREATE INDEX artist_tag_map_index_artist_id ON artist_tag_map(artist_id);
CREATE INDEX artist_tag_map_index_tag_id ON artist_tag_map(tag_id);
CREATE TABLE artist_members(
        artist_id       INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        PRIMARY KEY(artist_id, user_id) NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE INDEX artist_members_index_artist_id ON artist_members(artist_id);
CREATE INDEX artist_members_index_user_id ON artist_members(user_id);
CREATE TABLE venues(
        id              INTEGER PRIMARY KEY,
        address         TEXT,
        name            TEXT NOT NULL,
        website         TEXT
);
CREATE TABLE events(
        id                      INTEGER PRIMARY KEY,
        created_at              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description             TEXT,
        end_datetime            TEXT DEFAULT NULL, -- Remember to compute the default endtime (eg midnight the next day) if none when querying
        name                    TEXT DEFAULT NULL,     -- Remember to make this the top billing artist if null when querying
        organiser_id            INTEGER NOT NULL,      -- When querying, make default current user
        start_datetime          TEXT NOT NULL,
        venue_id                INTEGER,
        FOREIGN KEY(organiser_id) REFERENCES users(id),
        FOREIGN KEY(venue_id) REFERENCES venues(id)
);
CREATE INDEX events_index_organiser_id ON events(organiser_id);
CREATE INDEX events_index_venue_id ON events(venue_id);
CREATE TABLE event_artists(
        artist_id       INTEGER NOT NULL,
        event_id        INTEGER NOT NULL,
        PRIMARY KEY(artist_id, event_id) NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(event_id) REFERENCES events(id)
);
CREATE INDEX event_artists_index_artist_id ON event_artists(artist_id);
CREATE INDEX event_artists_index_event_id ON event_artists(event_id);
CREATE TABLE event_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg jam/open mic, genre etc
);
CREATE TABLE event_tag_map(
        event_id       INTEGER NOT NULL,
        tag_id          INTEGER NOT NULL,
        PRIMARY KEY(event_id, tag_id) NOT NULL,
        FOREIGN KEY(event_id) REFERENCES events(id),
        FOREIGN KEY(tag_id) REFERENCES event_tags(id)
);
CREATE INDEX event_tag_map_index_event_id ON event_tag_map(event_id);
CREATE INDEX event_tag_map_index_tag_id ON event_tag_map(tag_id);
CREATE TABLE opportunities(
        id                      INTEGER PRIMARY KEY,
        artist_id               INTEGER, -- optional
        body                    TEXT,
        created_at              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_id                INTEGER NOT NULL,
        expires_at              TEXT,
        title                   TEXT NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists(id),
        FOREIGN KEY(owner_id) REFERENCES users(id)
);
CREATE INDEX opportunities_index_artist_id ON opportunities(artist_id);
CREATE INDEX opportunities_index_owner_id ON opportunities(owner_id);
CREATE TABLE opportunity_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg permanent/temp, audition, looking for work etc
);
CREATE TABLE opportunity_tag_map(
        instrument_id           INTEGER,                -- eg guitarist, trumpeter...
        opportunity_id          INTEGER NOT NULL,
        opportunity_tag_id      INTEGER,                -- eg permanent/temp, audition, looking...
        role_id                INTEGER,                -- eg musician, photographer...
        FOREIGN KEY(instrument_id) REFERENCES instruments(id),
        FOREIGN KEY(opportunity_id) REFERENCES opportunities(id),
        FOREIGN KEY(opportunity_tag_id) REFERENCES opportunity_tags(id),
        FOREIGN KEY(role_id) REFERENCES roles(id)
);
-- index?
CREATE TABLE posts (
        id                      INTEGER PRIMARY KEY,
        author_id               INTEGER NOT NULL,
        body                    TEXT,
        created_at              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title                   TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES users (id)
);
