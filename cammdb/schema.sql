DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS instruments;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS types;
DROP TABLE IF EXISTS gigs;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS artists_members;
DROP TABLE IF EXISTS artists_tags;
DROP TABLE IF EXISTS users_instruments;
DROP TABLE IF EXISTS users_types;
DROP TABLE IF EXISTS gigs_artists;
DROP TABLE IF EXISTS gigs_tags;
DROP TABLE IF EXISTS opportunities_tags;
DROP TABLE IF EXISTS opportunities_types;

CREATE TABLE artists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        name TEXT NOT NULL
);
CREATE TABLE instruments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
);
CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        email TEXT,
        name TEXT UNIQUE NOT NULL,
        password TEXT
);
CREATE TABLE venues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT NOT NULL,
        name TEXT NOT NULL
);
CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
);
CREATE TABLE types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
);
CREATE TABLE gigs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        description TEXT,
        name TEXT NOT NULL,
        organiser_id INTEGER NOT NULL,
        venue_id INTEGER NOT NULL,
        FOREIGN KEY(organiser_id) REFERENCES users (id),
        FOREIGN KEY(venue_id) REFERENCES venues (id)
);
CREATE TABLE opportunities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        description TEXT,
        artist_id INTEGER,
        instrument_id INTEGER,
        organiser_id INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists (id),
        FOREIGN KEY(instrument_id) REFERENCES instruments (id),
        FOREIGN KEY(organiser_id) REFERENCES users (id)
);
CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        author_id INTEGER NOT NULL,
        created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES users (id)
);
CREATE TABLE artists_members (
        artist_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists (id),
        FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE artists_tags (
        artist_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists (id),
        FOREIGN KEY(tag_id) REFERENCES tags (id)
);
CREATE TABLE users_instruments (
        instrument_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY(instrument_id) REFERENCES instruments (id),
        FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE users_types (
        type_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY(type_id) REFERENCES types (id),
        FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE gigs_artists (
        artist_id INTEGER NOT NULL,
        gig_id INTEGER NOT NULL,
        FOREIGN KEY(artist_id) REFERENCES artists (id),
        FOREIGN KEY(gig_id) REFERENCES gigs (id)
);
CREATE TABLE gigs_tags (
        gig_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        FOREIGN KEY(gig_id) REFERENCES gigs (id),
        FOREIGN KEY(tag_id) REFERENCES tags (id)
);
CREATE TABLE opportunities_tags (
        opportunity_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        FOREIGN KEY(opportunity_id) REFERENCES opportunities (id),
        FOREIGN KEY(tag_id) REFERENCES tags (id)
);
CREATE TABLE opportunities_types (
        opportunity_id INTEGER NOT NULL,
        type_id INTEGER NOT NULL,
        FOREIGN KEY(opportunity_id) REFERENCES opportunities (id),
        FOREIGN KEY(type_id) REFERENCES types (id)
);
