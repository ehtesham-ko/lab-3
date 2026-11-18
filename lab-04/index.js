const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const { getDB } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;
const SECRET_KEY = "AURORA_DEV_SECRET_KEY_JWT_2026";

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    status: 'online',
    message: 'Lab 4: Registration, Login and JWT Authentication API',
    endpoints: {
      register: 'POST /register/',
      login: 'POST /login/',
      users: 'GET /users'
    }
  });
});

app.post('/register', async (req, res) => {
  try {
    const { username, name, password } = req.body;

    if (!username || !name || !password) {
      return res.status(400).json({ error: 'Username, name, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password is too short (minimum 6 characters required)' });
    }

    const db = await getDB();
    const existingUser = await db.get('SELECT * FROM user WHERE username = ?', [username]);

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    await db.run(
      'INSERT INTO user (username, name, password) VALUES (?, ?, ?)',
      [username, name, hashedPassword]
    );

    return res.status(200).json({ message: 'User created successfully' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/register/', async (req, res) => {
  try {
    const { username, name, password } = req.body;

    if (!username || !name || !password) {
      return res.status(400).json({ error: 'Username, name, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password is too short (minimum 6 characters required)' });
    }

    const db = await getDB();
    const existingUser = await db.get('SELECT * FROM user WHERE username = ?', [username]);

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    await db.run(
      'INSERT INTO user (username, name, password) VALUES (?, ?, ?)',
      [username, name, hashedPassword]
    );

    return res.status(200).json({ message: 'User created successfully' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    const db = await getDB();
    const user = await db.get('SELECT * FROM user WHERE username = ?', [username]);

    if (!user) {
      return res.status(400).json({ error: 'Invalid user' });
    }

    const isPasswordMatched = await bcrypt.compare(password, user.password);

    if (!isPasswordMatched) {
      return res.status(400).json({ error: 'Invalid password' });
    }

    const payload = { username: user.username };
    const jwtToken = jwt.sign(payload, SECRET_KEY, { expiresIn: '1h' });

    return res.status(200).json({ jwt_token: jwtToken });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/login/', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    const db = await getDB();
    const user = await db.get('SELECT * FROM user WHERE username = ?', [username]);

    if (!user) {
      return res.status(400).json({ error: 'Invalid user' });
    }

    const isPasswordMatched = await bcrypt.compare(password, user.password);

    if (!isPasswordMatched) {
      return res.status(400).json({ error: 'Invalid password' });
    }

    const payload = { username: user.username };
    const jwtToken = jwt.sign(payload, SECRET_KEY, { expiresIn: '1h' });

    return res.status(200).json({ jwt_token: jwtToken });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.get('/users', async (req, res) => {
  try {
    const db = await getDB();
    const users = await db.all('SELECT id, username, name, password FROM user');
    return res.status(200).json(users);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

let server = null;
if (require.main === module) {
  server = app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
  });
}

module.exports = { app, SECRET_KEY };
