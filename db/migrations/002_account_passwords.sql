BEGIN;

ALTER TABLE accounts
    ADD COLUMN username text UNIQUE,
    ADD COLUMN password_hash text,
    ADD CONSTRAINT accounts_username_check
        CHECK (
            username IS NULL OR (
                char_length(username) BETWEEN 3 AND 32
                AND username COLLATE "C" ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
            )
        ),
    ADD CONSTRAINT accounts_password_fields_check
        CHECK ((username IS NULL) = (password_hash IS NULL));

COMMIT;
