const http = require('http');
const app = require('./index');

function makeRequest(server, options, postData) {
  return new Promise((resolve, reject) => {
    const port = server.address().port;
    const reqOptions = {
      hostname: 'localhost',
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
          status: res.statusCode,
          headers: res.headers,
          body: parsed
        });
      });
    });

    req.on('error', (err) => reject(err));

    if (postData) {
      req.write(JSON.stringify(postData));
    }
    req.end();
  });
}

async function runTests() {
  const server = app.listen(0);
  try {
    const results = [];

    const t1 = await makeRequest(server, { method: 'GET', path: '/books' });
    results.push({ name: 'GET /books (all books)', expectedStatus: 200, actualStatus: t1.status, pass: t1.status === 200 && Array.isArray(t1.body.books), body: t1.body });

    const t2 = await makeRequest(server, { method: 'GET', path: '/books?search_q=Hobbit' });
    results.push({ name: 'GET /books?search_q=Hobbit', expectedStatus: 200, actualStatus: t2.status, pass: t2.status === 200 && t2.body.books.length > 0 && t2.body.books[0].title.includes('Hobbit'), body: t2.body });

    const t3 = await makeRequest(server, { method: 'GET', path: '/books?min_price=12&max_price=20' });
    results.push({ name: 'GET /books?min_price=12&max_price=20', expectedStatus: 200, actualStatus: t3.status, pass: t3.status === 200 && t3.body.books.every(b => b.price >= 12 && b.price <= 20), body: t3.body });

    const t4 = await makeRequest(server, { method: 'GET', path: '/books?order_by=price&order=DESC' });
    results.push({ name: 'GET /books?order_by=price&order=DESC', expectedStatus: 200, actualStatus: t4.status, pass: t4.status === 200 && t4.body.books[0].price >= t4.body.books[1].price, body: t4.body });

    const t5 = await makeRequest(server, { method: 'GET', path: '/books?limit=2&offset=2' });
    results.push({ name: 'GET /books?limit=2&offset=2 (pagination)', expectedStatus: 200, actualStatus: t5.status, pass: t5.status === 200 && t5.body.books.length <= 2, body: t5.body });

    const t6 = await makeRequest(server, { method: 'GET', path: '/books/1' });
    results.push({ name: 'GET /books/1 (existing book)', expectedStatus: 200, actualStatus: t6.status, pass: t6.status === 200 && t6.body.id === 1, body: t6.body });

    const t7 = await makeRequest(server, { method: 'GET', path: '/books/999' });
    results.push({ name: 'GET /books/999 (non-existent book)', expectedStatus: 404, actualStatus: t7.status, pass: t7.status === 404 && t7.body.message === 'Book not found', body: t7.body });

    const t8 = await makeRequest(server, { method: 'POST', path: '/books' }, { title: 'Designing Data-Intensive Applications', author: 'Martin Kleppmann', price: 45.00 });
    results.push({ name: 'POST /books (valid create)', expectedStatus: 201, actualStatus: t8.status, pass: t8.status === 201 && t8.body.book && t8.body.book.title === 'Designing Data-Intensive Applications', body: t8.body });

    const t9 = await makeRequest(server, { method: 'POST', path: '/books' }, { author: 'Martin Kleppmann', price: 45.00 });
    results.push({ name: 'POST /books (missing title)', expectedStatus: 400, actualStatus: t9.status, pass: t9.status === 400 && t9.body.message === 'Title is required', body: t9.body });

    const t10 = await makeRequest(server, { method: 'POST', path: '/books' }, { title: 'Some Title', price: 45.00 });
    results.push({ name: 'POST /books (missing author)', expectedStatus: 400, actualStatus: t10.status, pass: t10.status === 400 && t10.body.message === 'Author is required', body: t10.body });

    const t11 = await makeRequest(server, { method: 'POST', path: '/books' }, { title: 'Some Title', author: 'Some Author', price: 'invalid_price' });
    results.push({ name: 'POST /books (non-numeric price)', expectedStatus: 400, actualStatus: t11.status, pass: t11.status === 400 && t11.body.message === 'Price must be a valid non-negative number', body: t11.body });

    const t12 = await makeRequest(server, { method: 'PUT', path: '/books/1' }, { title: 'The Great Gatsby - Special Edition', author: 'F. Scott Fitzgerald', price: 15.99 });
    results.push({ name: 'PUT /books/1 (valid update)', expectedStatus: 200, actualStatus: t12.status, pass: t12.status === 200 && t12.body.book.title === 'The Great Gatsby - Special Edition', body: t12.body });

    const t13 = await makeRequest(server, { method: 'PUT', path: '/books/999' }, { title: 'Updated Title', author: 'Updated Author', price: 20.00 });
    results.push({ name: 'PUT /books/999 (update non-existent)', expectedStatus: 404, actualStatus: t13.status, pass: t13.status === 404 && t13.body.message === 'Book not found', body: t13.body });

    const t14 = await makeRequest(server, { method: 'DELETE', path: '/books/2' });
    results.push({ name: 'DELETE /books/2 (valid delete)', expectedStatus: 200, actualStatus: t14.status, pass: t14.status === 200 && t14.body.message === 'Book deleted successfully', body: t14.body });

    const t15 = await makeRequest(server, { method: 'DELETE', path: '/books/999' });
    results.push({ name: 'DELETE /books/999 (delete non-existent)', expectedStatus: 404, actualStatus: t15.status, pass: t15.status === 404 && t15.body.message === 'Book not found', body: t15.body });

    let allPassed = true;
    for (const res of results) {
      const statusIcon = res.pass ? 'PASS' : 'FAIL';
      console.log(`[${statusIcon}] ${res.name} -> Status: ${res.actualStatus} (Expected: ${res.expectedStatus})`);
      if (!res.pass) allPassed = false;
    }

    if (allPassed) {
      console.log('\nAll 15 API tests passed successfully!');
    } else {
      console.log('\nSome tests failed.');
      process.exitCode = 1;
    }
  } finally {
    server.close();
  }
}

runTests();
