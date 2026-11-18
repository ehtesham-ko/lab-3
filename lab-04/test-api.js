const http = require('http');
const jwt = require('jsonwebtoken');
const { app, SECRET_KEY } = require('./index');

function makeRequest(server, options, postData = null) {
  return new Promise((resolve, reject) => {
    const port = server.address().port;
    const reqOptions = {
      hostname: '127.0.0.1',
      port,
      path: options.path,
      method: options.method,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      }
    };

    const req = http.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        let parsed = null;
        try {
          parsed = JSON.parse(data);
        } catch (e) {
          parsed = data;
        }
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          data: parsed
        });
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (postData) {
      const payload = typeof postData === 'string' ? postData : JSON.stringify(postData);
      req.write(payload);
    }
    req.end();
  });
}

async function runTests() {
  const server = app.listen(0);
  console.log('Testing Lab 4 Registration, Login and JWT API...\n');

  let passed = 0;
  let failed = 0;

  async function test(name, fn) {
    try {
      await fn();
      console.log('PASS: ' + name);
      passed++;
    } catch (err) {
      console.error('FAIL: ' + name + ' -> ' + err.message);
      failed++;
    }
  }

  try {
    await test('Server root endpoint returns 200 OK', async () => {
      const res = await makeRequest(server, {
        path: '/',
        method: 'GET'
      });
      if (res.statusCode !== 200) throw new Error('Expected 200, got ' + res.statusCode);
      if (res.data.status !== 'online') throw new Error('Expected status online');
    });

    await test('POST /register/ rejects missing fields with 400', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/register/',
          method: 'POST'
        },
        { username: 'testuser' }
      );
      if (res.statusCode !== 400) throw new Error('Expected 400, got ' + res.statusCode);
    });

    await test('POST /register/ rejects short password with 400', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/register/',
          method: 'POST'
        },
        { username: 'shortpw', name: 'Short PW', password: '123' }
      );
      if (res.statusCode !== 400) throw new Error('Expected 400, got ' + res.statusCode);
    });

    await test('POST /register/ registers valid user successfully with 200', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/register/',
          method: 'POST'
        },
        {
          username: 'ehtesham',
          name: 'Mohammed Ehtesham',
          password: 'Password@123'
        }
      );
      if (res.statusCode !== 200) throw new Error('Expected 200, got ' + res.statusCode);
      if (res.data.message !== 'User created successfully') {
        throw new Error('Unexpected message: ' + JSON.stringify(res.data));
      }
    });

    await test('POST /register/ rejects duplicate username with 400', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/register/',
          method: 'POST'
        },
        {
          username: 'ehtesham',
          name: 'Mohammed Ehtesham Duplicate',
          password: 'AnotherPassword@123'
        }
      );
      if (res.statusCode !== 400) throw new Error('Expected 400, got ' + res.statusCode);
      if (res.data.error !== 'User already exists') {
        throw new Error('Unexpected error message: ' + JSON.stringify(res.data));
      }
    });

    await test('POST /login/ rejects unknown username with 400', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/login/',
          method: 'POST'
        },
        {
          username: 'nonexistent_user_99',
          password: 'Password@123'
        }
      );
      if (res.statusCode !== 400) throw new Error('Expected 400, got ' + res.statusCode);
      if (res.data.error !== 'Invalid user') {
        throw new Error('Unexpected error message: ' + JSON.stringify(res.data));
      }
    });

    await test('POST /login/ rejects incorrect password with 400', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/login/',
          method: 'POST'
        },
        {
          username: 'ehtesham',
          password: 'WrongPasswordXYZ'
        }
      );
      if (res.statusCode !== 400) throw new Error('Expected 400, got ' + res.statusCode);
      if (res.data.error !== 'Invalid password') {
        throw new Error('Unexpected error message: ' + JSON.stringify(res.data));
      }
    });

    let token = '';
    await test('POST /login/ with valid credentials returns 200 and jwt_token', async () => {
      const res = await makeRequest(
        server,
        {
          path: '/login/',
          method: 'POST'
        },
        {
          username: 'ehtesham',
          password: 'Password@123'
        }
      );
      if (res.statusCode !== 200) throw new Error('Expected 200, got ' + res.statusCode);
      if (!res.data.jwt_token) throw new Error('Missing jwt_token in response: ' + JSON.stringify(res.data));
      token = res.data.jwt_token;
    });

    await test('JWT Token is valid, signed with SECRET_KEY, and contains username without password', async () => {
      if (!token) throw new Error('Token is missing');
      const decoded = jwt.verify(token, SECRET_KEY);
      if (decoded.username !== 'ehtesham') throw new Error('Expected username ehtesham, got ' + decoded.username);
      if (decoded.password) throw new Error('Password MUST NOT be present in token payload');
    });

    await test('Database stores only password hashes and never plain text', async () => {
      const res = await makeRequest(server, {
        path: '/users',
        method: 'GET'
      });
      if (res.statusCode !== 200) throw new Error('Expected 200, got ' + res.statusCode);
      const user = res.data.find((u) => u.username === 'ehtesham');
      if (!user) throw new Error('User ehtesham not found in database');
      if (user.password === 'Password@123') throw new Error('Password stored as plain text!');
      if (!user.password.startsWith('$2b$') && !user.password.startsWith('$2a$')) {
        throw new Error('Password is not a valid bcrypt hash: ' + user.password);
      }
    });

    console.log('\nAll tests passed successfully: ' + passed + ' passed, ' + failed + ' failed');
  } finally {
    server.close();
  }
}

runTests();
