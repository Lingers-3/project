CREATE TABLE "Users" (
    "Id" SERIAL PRIMARY KEY,
    "Auth0ID" VARCHAR(255) NOT NULL UNIQUE,
    "Email" VARCHAR(255) NOT NULL UNIQUE,
    "NotifyOnExpiration" BOOLEAN NOT NULL DEFAULT TRUE,
    "NotifyOnDeadline" BOOLEAN NOT NULL DEFAULT TRUE,
    "NotifyOnThreshold" BOOLEAN NOT NULL DEFAULT TRUE,
    "NotifyOnInsufficientResources" BOOLEAN NOT NULL DEFAULT TRUE,

    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "DeletedAt" TIMESTAMPTZ
);

CREATE TABLE "Pictures" (
    "Id" SERIAL PRIMARY KEY,
    "BlobId" UUID NOT NULL,
    "Filetype" VARCHAR(8) NOT NULL,

    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "ItemTypes" (
    "Id" SERIAL PRIMARY KEY,

    "UserId" INTEGER NOT NULL,
    "PictureId" INTEGER NOT NULL UNIQUE,

    "Name" VARCHAR(255) NOT NULL,
    "Description" VARCHAR(512),
    "Category" VARCHAR(255),
    "BaseMeasurementUnit" VARCHAR(255) NOT NULL,
    "DefaultQuantity" REAL NOT NULL DEFAULT 1.0,
    "Width" REAL,
    "Height" REAL,
    "Depth" REAL,

    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "DeletedAt" TIMESTAMPTZ,

    CONSTRAINT "FK_ItemType_User"
        FOREIGN KEY ("UserId")
        REFERENCES "Users"("Id")
        ON DELETE CASCADE,

    CONSTRAINT "FK_ItemType_Picture"
        FOREIGN KEY ("PictureId")
        REFERENCES "Pictures"("Id")
        ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON "Users"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON "ItemTypes"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();
