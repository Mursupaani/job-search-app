import assert from "node:assert/strict";
import { randomBytes } from "node:crypto";
import { test } from "node:test";
import { Client } from "pg";
import { hashPassword, verifyAccountPassword } from "./account-password.ts";

test("verify a fictional account password using PostgreSQL", async (t) => {
  const client = new Client({ connectionTimeoutMillis: 5000 });
  t.after(() => client.end());
  await client.connect();

  const username = "fictional-greenhouse";
  const password = randomBytes(24).toString("base64url");
  const passwordHash = await hashPassword(password);
  const { rows: [account] } = await client.query<{ id: number }>(
    "INSERT INTO accounts (username, password_hash) VALUES ($1, $2) RETURNING id",
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
});
