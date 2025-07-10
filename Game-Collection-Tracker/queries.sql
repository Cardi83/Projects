-- Find all games that user owns
SELECT
    *
FROM "games"
WHERE "id" IN (
    SELECT "game_id" FROM "game_ownership" WHERE "user_id" = (
        SELECT "id" FROM "users" WHERE "username" = 'user456'
        )
);

-- Search for all games on the platform Nintendo where the status is 'owned'
SELECT
    *
FROM "games"
WHERE "platform" = 'Nintendo'
    AND "status" = 'owned'
;

-- Add a new user
INSERT INTO "users" ("username", "first_name", "last_name", "email", "created_at")
    VALUES ('user456', 'Squall', 'Leonhart', 'Squall.Leonhart@hotmail.com', CURRENT_TIMESTAMP);

-- Find games two users have in common
SELECT "games"."title"
FROM "games"
JOIN "ownership" ON "games"."id" = "ownership"."game_id"
JOIN "users" ON "ownership"."user_id" = "users"."id"
WHERE "users"."username" = 'user456' AND "ownership"."status" = 'owned'

INTERSECT

SELECT "games"."title"
FROM "games"
JOIN "ownership" ON "games"."id" = "ownership"."game_id"
JOIN "users" ON "ownership"."user_id" = "users"."id"
WHERE "users"."username" = 'user123' AND "ownership"."status" = 'owned'
;

-- Update the status and rating on a specific game
UPDATE "ownership"
SET
    "rating" = 10,
    "status" = 'owned'
WHERE "user_id" = (
        SELECT "id" FROM "users" WHERE "username" = 'user456'
        )
        AND "game_id" = (
            SELECT "id" FROM "games" WHERE "title" = 'Final Fantasy VII'
            )
;

-- Delete a game
DELETE
FROM "ownership"
WHERE "id" = 42
; -- Will execute the soft delete trigger
