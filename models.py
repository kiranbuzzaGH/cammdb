"""Define cammdb.db schema"""

from sqlalchemy import create_engine
from sqlalchemy import Column, ForeignKey, Integer, MetaData, String, Table
from sqlalchemy.dialects.sqlite import DATE

engine = create_engine("sqlite:///cammdb.db")

metadata_obj = MetaData()

artists = Table(
    "artists",
    metadata_obj,
    Column("description", String),
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False)
)

instruments = Table(
    "instruments",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False)
)

users = Table(
    "users",
    metadata_obj,
    Column("description", String),
    Column("email", String),
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False),
)

venues = Table(
    "venues",
    metadata_obj,
    Column("address", String, nullable=False),
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False)
)

tags = Table(
    "tags",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False)
)

types = Table(
    "types",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False)
)

gigs = Table(
    "gigs",
    metadata_obj,
    Column("date", DATE, nullable=False),
    Column("description", String),
    Column("id", Integer, primary_key=True),
    Column("name", String, nullable=False),
    Column("organiser_id", Integer, ForeignKey("users.id"), nullable=False),
    Column("venue_id", Integer, ForeignKey("venues.id"), nullable=False)
)

opportunities = Table(
    "opportunities",
    metadata_obj,
    Column("artist_id", Integer, ForeignKey("artists.id")),
    Column("date", DATE),
    Column("description", String),
    Column("id", Integer, primary_key=True),
    Column("instrument", Integer, ForeignKey("instruments.id")),
    Column("organiser", Integer, ForeignKey("users.id"), nullable=False)
)

artists_members = Table(
    "artists_members",
    metadata_obj,
    Column("artist_id", Integer, ForeignKey("artists.id"), nullable=False),
    Column("user_id", Integer, ForeignKey("users.id"), nullable=False)
)

artists_tags = Table(
    "artists_tags",
    metadata_obj,
    Column("artist_id", Integer, ForeignKey("artists.id"), nullable=False),
    Column("tag_id", Integer, ForeignKey("tags.id"), nullable=False)
)

gigs_artists = Table(
    "gigs_artists",
    metadata_obj,
    Column("artist_id", Integer, ForeignKey("artists.id"), nullable=False),
    Column("gig_id", Integer, ForeignKey("gigs.id"), nullable=False)
)

gigs_tags = Table(
    "gigs_tags",
    metadata_obj,
    Column("gig_id", Integer, ForeignKey("gigs.id"), nullable=False),
    Column("tag_id", Integer, ForeignKey("tags.id"), nullable=False)
)

opportunities_tags = Table(
    "opportunities_tags",
    metadata_obj,
    Column("opportunity_id", Integer, ForeignKey("opportunities.id"), nullable=False),
    Column("tag_id", Integer, ForeignKey("tags.id"), nullable=False)
)

opportunities_types = Table(
    "opportunities_types",
    metadata_obj,
    Column("opportunity_id", Integer, ForeignKey("opportunities.id"), nullable=False),
    Column("type_id", Integer, ForeignKey("types.id"), nullable=False)
)

users_instruments = Table(
    "users_instruments",
    metadata_obj,
    Column("instrument_id", Integer, ForeignKey("instruments.id"), nullable=False),
    Column("user_id", Integer, ForeignKey("users.id"), nullable=False)
)

users_type = Table(
    "users_type",
    metadata_obj,
    Column("type_id", Integer, ForeignKey("types.id"), nullable=False),
    Column("user_id", Integer, ForeignKey("users.id"), nullable=False)
)
