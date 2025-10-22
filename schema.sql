CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    auth0_id VARCHAR(256) NOT NULL UNIQUE,
    email VARCHAR(256) NOT NULL UNIQUE,
    notify_on_expiration BOOLEAN NOT NULL DEFAULT TRUE,
    notify_on_deadline BOOLEAN NOT NULL DEFAULT TRUE,
    notify_on_threshold BOOLEAN NOT NULL DEFAULT TRUE,
    notify_on_insufficient_resources BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE Pictures (
    id SERIAL PRIMARY KEY,
    blob_id UUID NOT NULL,
    filetype VARCHAR(8) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ItemTypes (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL,
    picture_id INTEGER,

    name VARCHAR(256) NOT NULL,
    description VARCHAR(512),
    category VARCHAR(256),
    base_measurement_unit VARCHAR(256) NOT NULL,
    default_quantity REAL NOT NULL DEFAULT 1.0,
    width REAL,
    height REAL,
    depth REAL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT FK_ItemType_User
        FOREIGN KEY (user_id)
        REFERENCES Users(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_ItemType_Picture
        FOREIGN KEY (picture_id)
        REFERENCES Pictures(id)
        ON DELETE CASCADE
);

-- hide when consumed, show when consumed, always visible
CREATE TYPE ConsumedVisibilityPolicy AS ENUM ('hide', 'show', 'visible');
CREATE TABLE Items (
    id SERIAL PRIMARY KEY,

    item_type_id INTEGER NOT NULL,
    -- display_measurement_unit_id INTEGER NOT NULL,
    -- stock_fill_measurement_unit_id INTEGER NOT NULL,

    quantity REAL NOT NULL DEFAULT 0,
    threshold REAL, -- for alerts
    expires_at TIMESTAMPZ,
    description VARCHAR(512),
    comsumed_policy VisibilityPolicy NOT NULL DEFAULT 'show',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT FK_ItemType_Item
        FOREIGN KEY (item_type_id)
        REFERENCES ItemTypes(id)
        ON DELETE CASCADE,
);

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON Users
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON ItemTypes
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON Items
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();
