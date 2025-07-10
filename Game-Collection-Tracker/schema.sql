-- Represents basic user account information
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "account_created_on" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

-- Represents general game metadata
CREATE TABLE "games" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "genre" TEXT,
    "release_year" NUMERIC,
    PRIMARY KEY("id")
);

-- Tracks which platforms users own specific games on
CREATE TABLE "platforms" (
    "id" INTEGER,
    "user_id" INTEGER,
    "game_id" INTEGER,
    "platform_name" TEXT NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("game_id") REFERENCES "games"("id")
);

-- Tracks game ownership status and details per user account
CREATE TABLE "ownership" (
    "id" INTEGER,
    "user_id" INTEGER,
    "game_id" INTEGER,
    "platform_id" INTEGER,
    "purchase_date" NUMERIC,
    "status" TEXT NOT NULL CHECK("status" IN ('owned', 'loaned', 'sold')),
    "physical_copy" NUMERIC CHECK("physical_copy" IN (0, 1)),
    "price_paid" NUMERIC CHECK("price_paid" >= 0),
    "rating" INTEGER CHECK("rating" >=1 AND "rating" <= 10),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("game_id") REFERENCES "games"("id"),
    FOREIGN KEY("platform_id") REFERENCES "platforms"("id")
);

-- Represents mutual connections between users
CREATE TABLE "friendship" (
    "id" INTEGER,
    "user_id" INTEGER,
    "friend_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("friend_id") REFERENCES "users"("id"),
    CHECK ("user_id" != "friend_id"),
    CHECK ("user_id" < "friend_id"),
    UNIQUE ("user_id", "friend_id")
);

-- Create a soft-delete trigger to change status to "sold"
CREATE TRIGGER "soft_delete_ownership"
BEFORE DELETE ON "ownership"
FOR EACH ROW
BEGIN
    UPDATE "ownership"
    SET
        "status" = 'sold'
    WHERE "id" = OLD."id"
;
END;

-- Index for quickly finding games a user owns
CREATE INDEX "owner_search" ON "ownership" ("user_id");
-- Index for searching games by title
CREATE INDEX "game_search" ON "games" ("title");
-- Index for searching users by full name
CREATE INDEX "name_of_user_search" ON "users" ("first_name", "last_name");
-- Index for searching users by username
CREATE INDEX "username_search" ON "users" ("username");
-- Index for optimizing friend lookups
CREATE INDEX "friendship_search" ON "friendship" ("user_id", "friend_id");

-- Create view for users who are friends with each other
CREATE VIEW "friends_view" AS
SELECT
    "u1"."id" AS "user_id",
    "u1"."username" AS "user_username",
    "u2"."id" AS "friend_id",
    "u2"."username" AS "friend_username"
FROM "friendship"
JOIN "users" AS "u1" ON "friendship"."user_id" = "u1"."id"
JOIN "users" AS "u2" ON "friendship"."friend_id" = "u2"."id"
WHERE "u1"."id" < "u2"."id" -- avoids duplicates
    AND "u1"."id" != "u2"."id"  -- avoids self-friendship
;
