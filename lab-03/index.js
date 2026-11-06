const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { getDB } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const ALLOWED_ORDER_BY = ['id', 'title', 'author', 'price'];
const ALLOWED_ORDER = ['ASC', 'DESC'];

app.get('/books', async (req, res) => {
  try {
    const db = await getDB();
    const {
      search_q = '',
      order_by = 'id',
      order = 'ASC',
      limit = '10',
      offset = '0',
      min_price,
      max_price
    } = req.query;

    const validatedOrderBy = ALLOWED_ORDER_BY.includes(String(order_by).toLowerCase())
      ? String(order_by).toLowerCase()
      : 'id';

    const validatedOrder = ALLOWED_ORDER.includes(String(order).toUpperCase())
      ? String(order).toUpperCase()
      : 'ASC';

    const parsedLimit = Math.max(1, parseInt(limit, 10) || 10);
    const parsedOffset = Math.max(0, parseInt(offset, 10) || 0);

    let query = 'SELECT * FROM books WHERE 1=1';
    const params = [];

    if (search_q && search_q.trim() !== '') {
      query += ' AND title LIKE ?';
      params.push(`%${search_q.trim()}%`);
    }

    const hasMin = min_price !== undefined && min_price !== '' && !isNaN(Number(min_price));
    const hasMax = max_price !== undefined && max_price !== '' && !isNaN(Number(max_price));

    if (hasMin && hasMax) {
      query += ' AND price BETWEEN ? AND ?';
      params.push(Number(min_price), Number(max_price));
    } else if (hasMin) {
      query += ' AND price >= ?';
      params.push(Number(min_price));
    } else if (hasMax) {
      query += ' AND price <= ?';
      params.push(Number(max_price));
    }

    query += ` ORDER BY ${validatedOrderBy} ${validatedOrder} LIMIT ? OFFSET ?`;
    params.push(parsedLimit, parsedOffset);

    const books = await db.all(query, params);
    return res.status(200).json({
      count: books.length,
      limit: parsedLimit,
      offset: parsedOffset,
      books
    });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.get('/books/:id', async (req, res) => {
  try {
    const db = await getDB();
    const { id } = req.params;
    const book = await db.get('SELECT * FROM books WHERE id = ?', [id]);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    return res.status(200).json(book);
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.post('/books', async (req, res) => {
  try {
    const { title, author, price } = req.body;

    if (!title || typeof title !== 'string' || title.trim() === '') {
      return res.status(400).json({ message: 'Title is required' });
    }
    if (!author || typeof author !== 'string' || author.trim() === '') {
      return res.status(400).json({ message: 'Author is required' });
    }
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) < 0) {
      return res.status(400).json({ message: 'Price must be a valid non-negative number' });
    }

    const db = await getDB();
    const result = await db.run(
      'INSERT INTO books (title, author, price) VALUES (?, ?, ?)',
      [title.trim(), author.trim(), Number(price)]
    );

    const newBook = await db.get('SELECT * FROM books WHERE id = ?', [result.lastID]);
    return res.status(201).json({
      message: 'Book created successfully',
      book: newBook
    });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.put('/books/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author, price } = req.body;

    const db = await getDB();
    const existingBook = await db.get('SELECT * FROM books WHERE id = ?', [id]);
    if (!existingBook) {
      return res.status(404).json({ message: 'Book not found' });
    }

    if (!title || typeof title !== 'string' || title.trim() === '') {
      return res.status(400).json({ message: 'Title is required' });
    }
    if (!author || typeof author !== 'string' || author.trim() === '') {
      return res.status(400).json({ message: 'Author is required' });
    }
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) < 0) {
      return res.status(400).json({ message: 'Price must be a valid non-negative number' });
    }

    await db.run(
      'UPDATE books SET title = ?, author = ?, price = ? WHERE id = ?',
      [title.trim(), author.trim(), Number(price), id]
    );

    const updatedBook = await db.get('SELECT * FROM books WHERE id = ?', [id]);
    return res.status(200).json({
      message: 'Book updated successfully',
      book: updatedBook
    });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.delete('/books/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const db = await getDB();
    const existingBook = await db.get('SELECT * FROM books WHERE id = ?', [id]);
    if (!existingBook) {
      return res.status(404).json({ message: 'Book not found' });
    }

    await db.run('DELETE FROM books WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Book deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}

module.exports = app;
