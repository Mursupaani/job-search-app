-- Read the fictional input into psql variables so the inserts and checks use
-- the same text, including the newlines and leading spaces.
SELECT E'Greenhouse assistant\n  Water seedlings and label trays.\n' AS linked_text,
       E'Seed library assistant\n  Sort and label seed packets.\n' AS unlinked_text,
       'https://example.com/jobs/greenhouse-assistant' AS source_url,
       clock_timestamp() AS started_at
\gset

INSERT INTO accounts DEFAULT VALUES
RETURNING id AS account_id
\gset

INSERT INTO job_postings (owner_id, original_text, source_url)
VALUES (:account_id, :'linked_text', :'source_url')
RETURNING id AS linked_id
\gset

INSERT INTO job_postings (owner_id, original_text)
VALUES (:account_id, :'unlinked_text')
RETURNING id AS unlinked_id
\gset

SELECT clock_timestamp() AS finished_at
\gset

-- A failed check raises an error and causes psql to exit unsuccessfully.
CREATE TEMP TABLE test_results (
    test_name text NOT NULL,
    passed boolean NOT NULL CHECK (passed)
);

INSERT INTO test_results (test_name, passed)
VALUES (
    'Read the linked posting by ID with its exact text, owner, URL and creation time',
    EXISTS (
        SELECT 1 FROM job_postings
        WHERE id = :linked_id
          AND owner_id = :account_id
          AND original_text = :'linked_text'
          AND source_url = :'source_url'
          AND created_at BETWEEN :'started_at' AND :'finished_at'
    )
), (
    'Read the unlinked posting by ID with its exact text, owner, NULL URL and creation time',
    EXISTS (
        SELECT 1 FROM job_postings
        WHERE id = :unlinked_id
          AND owner_id = :account_id
          AND original_text = :'unlinked_text'
          AND source_url IS NULL
          AND created_at BETWEEN :'started_at' AND :'finished_at'
    )
);

-- Allow the expected error so we can verify its PostgreSQL error code.
\echo Expecting a foreign-key violation for owner ID 0.
\set ON_ERROR_STOP off
INSERT INTO job_postings (owner_id, original_text)
VALUES (0, 'Fictional posting with no matching account');
\set ON_ERROR_STOP on

INSERT INTO test_results (test_name, passed)
VALUES ('Reject a nonexistent owner with a foreign-key violation', :'SQLSTATE' = '23503');

TABLE test_results;
