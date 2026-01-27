-- To be safe, always explicitly enable foreign keys
PRAGMA foreign_keys = ON;


-- Drop tables and indexes in reverse order to prevent any issues with foreign keys and already dropped tables
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
        created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        display_name    TEXT CHECK (display_name IS NULL OR length(trim(display_name)) > 0),
        email           TEXT NOT NULL UNIQUE COLLATE NOCASE,
        is_admin        INTEGER NOT NULL DEFAULT 0 CHECK (is_admin IN (0,1)),
        name            TEXT NOT NULL CHECK(length(trim(name)) > 0),
        password        TEXT  -- Note, stored as hash
) STRICT;
CREATE TABLE roles(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg musician, photographer etc
);
CREATE TABLE user_roles(
        role_id         INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        PRIMARY KEY(role_id, user_id),
        FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS user_roles_index_user_id ON user_roles(user_id);
CREATE TABLE instruments(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL
);
CREATE TABLE user_instruments(
        instrument_id   INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,       -- Only if role musician
        PRIMARY KEY(instrument_id, user_id),
        FOREIGN KEY(instrument_id) REFERENCES instruments(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS user_instruments_index_user_id ON user_instruments(user_id);
CREATE TABLE artists(
        id                      INTEGER PRIMARY KEY,
        bio                     TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_user_id           INTEGER NOT NULL, -- When querying, make default the creator
        name                    TEXT NOT NULL CHECK(length(trim(name)) > 0),
        FOREIGN KEY(owner_user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
CREATE INDEX IF NOT EXISTS artists_index_owner_user_id ON artists(owner_user_id);
CREATE TABLE artist_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg genre, type (originals/covers/acoustic), status
);
CREATE TABLE artist_tag_map(
        artist_id               INTEGER NOT NULL,
        artist_tag_id           INTEGER NOT NULL,
        PRIMARY KEY(artist_id, artist_tag_id),
        FOREIGN KEY(artist_id) REFERENCES artists(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(artist_tag_id) REFERENCES artist_tags(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS artist_tag_map_index_artist_tag_id ON artist_tag_map(artist_tag_id);
CREATE TABLE artist_members(
        artist_id       INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        PRIMARY KEY(artist_id, user_id),
        FOREIGN KEY(artist_id) REFERENCES artists(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS artist_members_index_user_id ON artist_members(user_id);
CREATE TABLE venues(
        id              INTEGER PRIMARY KEY,
        address         TEXT,
        name            TEXT NOT NULL CHECK(length(trim(name)) > 0),
        website         TEXT
) STRICT;
CREATE TABLE events(
        id                      INTEGER PRIMARY KEY,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description             TEXT,
        end_datetime            TIMESTAMP, -- Remember to compute the default endtime (eg midnight the next day) if none when querying
        name                    TEXT CHECK(name IS NULL OR length(trim(name)) > 0),     -- Remember to make this the top billing artist if null when querying
        organiser_user_id       INTEGER NOT NULL,
        start_datetime          TIMESTAMP NOT NULL,
        venue_id                INTEGER,
        FOREIGN KEY(organiser_user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE, --when querying, if null, use "deleted user" placeholder
        FOREIGN KEY(venue_id) REFERENCES venues(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
CREATE INDEX IF NOT EXISTS events_index_organiser_user_id ON events(organiser_user_id);
CREATE INDEX IF NOT EXISTS events_index_venue_id ON events(venue_id);
CREATE TABLE event_artists(
        artist_id       INTEGER NOT NULL,
        event_id        INTEGER NOT NULL,
        PRIMARY KEY(artist_id, event_id),
        FOREIGN KEY(artist_id) REFERENCES artists(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS event_artists_index_event_id ON event_artists(event_id);
CREATE TABLE event_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg jam/open mic, genre etc
);
CREATE TABLE event_tag_map(
        event_id              INTEGER NOT NULL,
        event_tag_id          INTEGER NOT NULL,
        PRIMARY KEY(event_id, event_tag_id),
        FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(event_tag_id) REFERENCES event_tags(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS event_tag_map_index_event_tag_id ON event_tag_map(event_tag_id);
CREATE TABLE opportunities(
        id                      INTEGER PRIMARY KEY,
        artist_id               INTEGER, -- optional
        body                    TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        owner_user_id           INTEGER NOT NULL,
        expires_at              TIMESTAMP,
        title                   TEXT NOT NULL CHECK(length(trim(title)) > 0),
        FOREIGN KEY(artist_id) REFERENCES artists(id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY(owner_user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
CREATE INDEX IF NOT EXISTS opportunities_index_artist_id ON opportunities(artist_id);
CREATE INDEX IF NOT EXISTS opportunities_index_owner_user_id ON opportunities(owner_user_id);
CREATE TABLE opportunity_tags(
        id      INTEGER PRIMARY KEY,
        name    TEXT UNIQUE NOT NULL   -- Eg permanent/temp, audition, looking for work etc
);
CREATE TABLE opportunity_instruments(
        instrument_id   INTEGER NOT NULL,       -- eg guitarist, trumpeter...
        opportunity_id  INTEGER NOT NULL,
        PRIMARY KEY(instrument_id, opportunity_id),
        FOREIGN KEY(instrument_id) REFERENCES instruments(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS opportunity_instruments_index_opportunity_id ON opportunity_instruments(opportunity_id);
CREATE TABLE opportunity_roles(
        opportunity_id          INTEGER NOT NULL,
        role_id                 INTEGER NOT NULL,                -- eg musician, photographer...
        PRIMARY KEY(opportunity_id, role_id),
        FOREIGN KEY(opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS opportunity_roles_index_role_id ON opportunity_roles(role_id);
CREATE TABLE opportunity_tag_map(
        opportunity_id          INTEGER NOT NULL,
        opportunity_tag_id      INTEGER NOT NULL,                -- eg permanent/temp, audition, looking...
        PRIMARY KEY(opportunity_id, opportunity_tag_id),
        FOREIGN KEY(opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(opportunity_tag_id) REFERENCES opportunity_tags(id) ON DELETE CASCADE ON UPDATE CASCADE
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS opportunity_tag_map_index_opportunity_tag_id ON opportunity_tag_map(opportunity_tag_id);
CREATE TABLE posts (
        id                      INTEGER PRIMARY KEY,
        author_user_id          INTEGER NOT NULL,
        body                    TEXT,
        created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title                   TEXT NOT NULL CHECK(length(trim(title)) > 0),
        FOREIGN KEY (author_user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
CREATE INDEX IF NOT EXISTS posts_index_author_user_id ON posts(author_user_id);
