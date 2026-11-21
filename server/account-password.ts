import { argon2, randomBytes, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";
import type { Client } from "pg";

const argon2Async = promisify(argon2);
const saltLength = 16;
const hashOptions = { memory: 19 * 1024, passes: 2, parallelism: 1, tagLength: 32 };
const hashPrefix = `$argon2id$v=19$m=${hashOptions.memory},t=${hashOptions.passes},p=${hashOptions.parallelism}$`;

function derivePasswordKey(password: string, salt: Buffer): Promise<Buffer> {
  return argon2Async("argon2id", { ...hashOptions, message: password, nonce: salt });
}

function encodeHashPart(bytes: Buffer): string {
  return bytes.toString("base64").replace(/=+$/, "");
}

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(saltLength);
  const key = await derivePasswordKey(password, salt);
  return `${hashPrefix}${encodeHashPart(salt)}$${encodeHashPart(key)}`;
}

async function matchesPassword(password: string, storedHash: string): Promise<boolean> {
  const [encodedSalt = "", encodedKey = "", extra] = storedHash.slice(hashPrefix.length).split("$");
  const salt = Buffer.from(encodedSalt, "base64");
  const storedKey = Buffer.from(encodedKey, "base64");
  const validHash = storedHash.startsWith(hashPrefix) && extra === undefined &&
    salt.length === saltLength && storedKey.length === hashOptions.tagLength &&
    encodeHashPart(salt) === encodedSalt && encodeHashPart(storedKey) === encodedKey;

  // Do the same costly hashing work when the username has no usable hash.
  const key = await derivePasswordKey(password, validHash ? salt : Buffer.alloc(saltLength));
  const matches = timingSafeEqual(key, validHash ? storedKey : Buffer.alloc(hashOptions.tagLength));
  return validHash && matches;
}

export async function verifyAccountPassword(
  client: Client,
  username: string,
  password: string,
): Promise<number | null> {
  const { rows } = await client.query<{ id: number; password_hash: string }>(
    "SELECT id, password_hash FROM accounts WHERE username = $1",
    [username],
  );
  const account = rows[0];
  const matches = await matchesPassword(password, account?.password_hash ?? "");
  return matches ? account.id : null;
}
