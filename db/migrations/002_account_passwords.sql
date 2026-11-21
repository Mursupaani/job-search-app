BEGIN;

ALTER TABLE accounts
    ADD COLUMN username text UNIQUE,
    ADD COLUMN password_hash text,
    ADD CONSTRAINT accounts_username_check
        CHECK (username IS NULL OR (username <> '' AND strpos(username, '@') = 0)),
    ADD CONSTRAINT accounts_password_fields_check
        CHECK ((username IS NULL) = (password_hash IS NULL));

COMMIT;
