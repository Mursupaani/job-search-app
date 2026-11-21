import assert from "node:assert/strict";
import { randomBytes } from "node:crypto";
import { test } from "node:test";
import { Client } from "pg";
import { hashPassword, verifyAccountPassword } from "./account-password.ts";

test("verify a fictional account password using PostgreSQL", async (t) => {
  const client = new Client({ connectionTimeoutMillis: 5000 });
  t.after(() => client.end());
  await client.connect();

  const username = "fictional-greenhouse-2";
  const password = randomBytes(24).toString("base64url");
  const passwordHash = await hashPassword(password);
  const insertAccount = "INSERT INTO accounts (username, password_hash) VALUES ($1, $2) RETURNING id";
  const { rows: [account] } = await client.query<{ id: number }>(
    insertAccount,
    [username, passwordHash],
  );

  await t.test("the correct password returns the account ID", async () => {
    assert.equal(await verifyAccountPassword(client, username, password), account.id);
  });

  await t.test("a wrong password returns no account ID", async () => {
    assert.equal(await verifyAccountPassword(client, username, `${password}-wrong`), null);
  });

  await t.test("an unknown username returns no account ID", async () => {
    assert.equal(await verifyAccountPassword(client, "fictional-unknown", password), null);
  });

  await t.test("PostgreSQL accepts usernames at both length limits", async () => {
    for (const validUsername of ["a-1", `${"a".repeat(30)}-1`]) {
      const { rowCount } = await client.query(
        "UPDATE accounts SET username = $1 WHERE id = $2",
        [validUsername, account.id],
      );
      assert.equal(rowCount, 1);
    }
  });

  await t.test("PostgreSQL rejects usernames outside the allowed format", async () => {
    const invalidUsernames = [
      "",
      "ab",
      "a".repeat(33),
      "fictional@example.com",
      "fictional greenhouse",
      "fictional_greenhouse",
      "fictional.greenhouse",
      "Fictional",
      "fíctional",
      "-fictional",
      "fictional-",
      "fictional--greenhouse",
      "fictional\n",
    ];
    for (const invalidUsername of invalidUsernames) {
      await assert.rejects(
        client.query(insertAccount, [invalidUsername, passwordHash]),
        { code: "23514", constraint: "accounts_username_check" },
        `Expected PostgreSQL to reject ${JSON.stringify(invalidUsername)}`,
      );
    }
  });
});
