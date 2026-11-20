BEGIN;

CREATE TABLE accounts (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

CREATE TABLE job_postings (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id integer NOT NULL REFERENCES accounts (id),
    original_text text NOT NULL,
    source_url text,
    created_at timestamptz NOT NULL DEFAULT statement_timestamp()
);

COMMIT;
