import { drizzle } from 'drizzle-orm/node-postgres';
import { Client } from 'pg';
import 'dotenv/config';

const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'neon',
  password: process.env.NEON_PASSWORD,
  database: 'neondb',
});

await client.connect();

export const db = drizzle(client);
