const path = require('path');
const { open } = require('sqlite');
const sqlite3 = require('sqlite3');
require('dotenv').config();

const dbPath = process.env.DB_PATH || path.join(__dirname, 'books.db');

let dbInstance = null;

async function getDB() {
  if (!dbInstance) {
    dbInstance = await open({
      filename: dbPath,
      driver: sqlite3.Database
    });
    await dbInstance.exec(`
      CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL
      );
    `);
    const count = await dbInstance.get('SELECT COUNT(*) as count FROM books');
    if (count.count === 0) {
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['The Great Gatsby', 'F. Scott Fitzgerald', 10.99]
      );
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['To Kill a Mockingbird', 'Harper Lee', 12.50]
      );
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['1984', 'George Orwell', 8.99]
      );
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['The Hobbit', 'J.R.R. Tolkien', 14.95]
      );
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['Atomic Habits', 'James Clear', 16.20]
      );
      await dbInstance.run(
        'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
        ['Clean Code', 'Robert C. Martin', 32.50]
      );
    }
  }
  return dbInstance;
}

module.exports = { getDB };
