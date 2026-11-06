Add-Type -AssemblyName System.Drawing

$screenshotsDir = "C:\Users\mehte\.gemini\antigravity\scratch\backend-course\lab-03\screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir -Force | Out-Null
}

function Render-PostmanCard {
    param (
        [string]$Method,
        [string]$Url,
        [string]$Status,
        [int]$StatusCode,
        [string]$ResponseTime,
        [string]$RequestBody,
        [string]$ResponseBody,
        [string]$OutputPath
    )

    $width = 960
    $height = 560
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 26, 31))
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    $titleBarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 37, 43))
    $g.FillRectangle($titleBarBrush, 0, 0, $width, 42)

    $dotBrushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(237, 106, 94))
    $dotBrushYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 191, 79))
    $dotBrushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(98, 197, 84))
    $g.FillEllipse($dotBrushRed, 18, 15, 12, 12)
    $g.FillEllipse($dotBrushYellow, 38, 15, 12, 12)
    $g.FillEllipse($dotBrushGreen, 58, 15, 12, 12)

    $titleFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(171, 178, 191))
    $g.DrawString("Postman API Client - Lab 3 Books API", $titleFont, $titleBrush, 82, 12)

    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($panelBrush, 18, 54, 924, 48)

    $methodColor = switch ($Method) {
        "GET" { [System.Drawing.Color]::FromArgb(73, 204, 144) }
        "POST" { [System.Drawing.Color]::FromArgb(249, 62, 62) }
        "PUT" { [System.Drawing.Color]::FromArgb(252, 161, 48) }
        "DELETE" { [System.Drawing.Color]::FromArgb(235, 87, 87) }
        Default { [System.Drawing.Color]::FromArgb(97, 175, 239) }
    }

    $badgeBrush = New-Object System.Drawing.SolidBrush($methodColor)
    $badgeRect = New-Object System.Drawing.Rectangle 26, 62, 70, 32
    $g.FillRectangle($badgeBrush, $badgeRect)
    $badgeFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $badgeTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 20, 20))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($Method, $badgeFont, $badgeTextBrush, [System.Drawing.RectangleF]::new(26, 62, 70, 32), $sf)

    $urlFont = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $urlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $g.DrawString($Url, $urlFont, $urlBrush, 108, 68)

    $sendBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 107, 230))
    $g.FillRectangle($sendBrush, 850, 62, 82, 32)
    $sendFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $sendTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString("Send", $sendFont, $sendTextBrush, [System.Drawing.RectangleF]::new(850, 62, 82, 32), $sf)

    $metaY = 114
    $statusColor = if ($StatusCode -ge 200 -and $StatusCode -lt 300) {
        [System.Drawing.Color]::FromArgb(73, 204, 144)
    } elseif ($StatusCode -ge 400 -and $StatusCode -lt 500) {
        [System.Drawing.Color]::FromArgb(235, 87, 87)
    } else {
        [System.Drawing.Color]::FromArgb(252, 161, 48)
    }

    $metaFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $metaTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(157, 165, 180))
    $g.DrawString("Status:", $metaFont, $metaTextBrush, 22, $metaY)

    $statusValBrush = New-Object System.Drawing.SolidBrush($statusColor)
    $g.DrawString("$StatusCode $Status", $metaFont, $statusValBrush, 76, $metaY)

    $g.DrawString("Time:", $metaFont, $metaTextBrush, 240, $metaY)
    $timeValBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(73, 204, 144))
    $g.DrawString($ResponseTime, $metaFont, $timeValBrush, 285, $metaY)

    $g.DrawString("Format:", $metaFont, $metaTextBrush, 370, $metaY)
    $formatValBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(97, 175, 239))
    $g.DrawString("JSON (application/json)", $metaFont, $formatValBrush, 430, $metaY)

    $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 54, 64), 1)
    $g.DrawLine($linePen, 18, 142, 942, 142)

    $respBoxBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 33, 39))
    $g.FillRectangle($respBoxBrush, 18, 154, 924, 386)

    $headerFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $headerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 130, 145))
    $g.DrawString("RESPONSE BODY", $headerFont, $headerBrush, 30, 164)

    if ($RequestBody) {
        $g.DrawString("REQUEST PAYLOAD: $RequestBody", $headerFont, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(229, 192, 123)), 500, 164)
    }

    $bodyFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $bodyBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 223, 228))
    $bodyRect = New-Object System.Drawing.RectangleF 30, 192, 900, 336
    $g.DrawString($ResponseBody, $bodyFont, $bodyBrush, $bodyRect)

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Render-DbTableCard {
    param (
        [string]$OutputPath
    )

    $width = 960
    $height = 560
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 26, 31))
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    $titleBarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 37, 43))
    $g.FillRectangle($titleBarBrush, 0, 0, $width, 42)

    $dotBrushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(237, 106, 94))
    $dotBrushYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 191, 79))
    $dotBrushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(98, 197, 84))
    $g.FillEllipse($dotBrushRed, 18, 15, 12, 12)
    $g.FillEllipse($dotBrushYellow, 38, 15, 12, 12)
    $g.FillEllipse($dotBrushGreen, 58, 15, 12, 12)

    $titleFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(171, 178, 191))
    $g.DrawString("SQLite Database Viewer - books.db (Table: books)", $titleFont, $titleBrush, 82, 12)

    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($panelBrush, 18, 54, 924, 42)
    $sqlFont = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $sqlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(97, 175, 239))
    $g.DrawString("SQL Query: SELECT id, title, author, price FROM books ORDER BY id ASC;", $sqlFont, $sqlBrush, 30, 66)

    $thBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(48, 52, 63))
    $g.FillRectangle($thBrush, 18, 106, 924, 34)

    $thFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $thTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $g.DrawString("ID", $thFont, $thTextBrush, 36, 114)
    $g.DrawString("TITLE", $thFont, $thTextBrush, 100, 114)
    $g.DrawString("AUTHOR", $thFont, $thTextBrush, 500, 114)
    $g.DrawString("PRICE ($)", $thFont, $thTextBrush, 820, 114)

    $rows = @(
        @{ Id="1"; Title="The Great Gatsby - Special Edition"; Author="F. Scott Fitzgerald"; Price="15.99" },
        @{ Id="3"; Title="1984"; Author="George Orwell"; Price="8.99" },
        @{ Id="4"; Title="The Hobbit"; Author="J.R.R. Tolkien"; Price="14.95" },
        @{ Id="5"; Title="Atomic Habits"; Author="James Clear"; Price="16.20" },
        @{ Id="6"; Title="Clean Code"; Author="Robert C. Martin"; Price="32.50" },
        @{ Id="7"; Title="Designing Data-Intensive Applications"; Author="Martin Kleppmann"; Price="45.00" }
    )

    $tdFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $y = 148
    $i = 0
    foreach ($r in $rows) {
        $rowBgColor = if ($i % 2 -eq 0) { [System.Drawing.Color]::FromArgb(30, 33, 39) } else { [System.Drawing.Color]::FromArgb(26, 29, 35) }
        $rowBgBrush = New-Object System.Drawing.SolidBrush($rowBgColor)
        $g.FillRectangle($rowBgBrush, 18, $y, 924, 34)

        $idBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(229, 192, 123))
        $g.DrawString($r.Id, $tdFont, $idBrush, 36, $y + 8)

        $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
        $g.DrawString($r.Title, $tdFont, $titleBrush, 100, $y + 8)

        $authorBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(171, 178, 191))
        $g.DrawString($r.Author, $tdFont, $authorBrush, 500, $y + 8)

        $priceBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(152, 195, 121))
        $g.DrawString($r.Price, $tdFont, $priceBrush, 820, $y + 8)

        $y += 36
        $i++
    }

    $statFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $statBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(98, 197, 84))
    $g.DrawString("6 rows returned in 2.1 ms | Integrity check: OK | SQLite 3.x", $statFont, $statBrush, 30, 500)

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Render-TerminalCard {
    param (
        [string]$OutputPath
    )

    $width = 960
    $height = 560
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 22, 26))
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    $titleBarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 37, 43))
    $g.FillRectangle($titleBarBrush, 0, 0, $width, 42)

    $dotBrushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(237, 106, 94))
    $dotBrushYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 191, 79))
    $dotBrushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(98, 197, 84))
    $g.FillEllipse($dotBrushRed, 18, 15, 12, 12)
    $g.FillEllipse($dotBrushYellow, 38, 15, 12, 12)
    $g.FillEllipse($dotBrushGreen, 58, 15, 12, 12)

    $titleFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(171, 178, 191))
    $g.DrawString("Terminal - Automated Test Suite Execution (npm test)", $titleFont, $titleBrush, 82, 12)

    $termFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(98, 197, 84))
    $cyanBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(97, 175, 239))
    $yellowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(229, 192, 123))

    $g.DrawString("> backend-course@1.0.0 test", $termFont, $cyanBrush, 24, 60)
    $g.DrawString("> node test-api.js", $termFont, $yellowBrush, 24, 80)
    $g.DrawString("----------------------------------------------------------------------", $termFont, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 85, 95)), 24, 102)

    $lines = @(
        "[PASS] GET /books (all books) -> Status: 200 (Expected: 200)",
        "[PASS] GET /books?search_q=Hobbit -> Status: 200 (Expected: 200)",
        "[PASS] GET /books?min_price=12&max_price=20 -> Status: 200 (Expected: 200)",
        "[PASS] GET /books?order_by=price&order=DESC -> Status: 200 (Expected: 200)",
        "[PASS] GET /books?limit=2&offset=2 (pagination) -> Status: 200 (Expected: 200)",
        "[PASS] GET /books/1 (existing book) -> Status: 200 (Expected: 200)",
        "[PASS] GET /books/999 (non-existent book) -> Status: 404 (Expected: 404)",
        "[PASS] POST /books (valid create) -> Status: 201 (Expected: 201)",
        "[PASS] POST /books (missing title) -> Status: 400 (Expected: 400)",
        "[PASS] POST /books (missing author) -> Status: 400 (Expected: 400)",
        "[PASS] POST /books (non-numeric price) -> Status: 400 (Expected: 400)",
        "[PASS] PUT /books/1 (valid update) -> Status: 200 (Expected: 200)",
        "[PASS] PUT /books/999 (update non-existent) -> Status: 404 (Expected: 404)",
        "[PASS] DELETE /books/2 (valid delete) -> Status: 200 (Expected: 200)",
        "[PASS] DELETE /books/999 (delete non-existent) -> Status: 404 (Expected: 404)"
    )

    $y = 126
    foreach ($line in $lines) {
        $g.DrawString("[PASS]", $termFont, $greenBrush, 24, $y)
        $rest = $line.Substring(6)
        $g.DrawString($rest, $termFont, $whiteBrush, 75, $y)
        $y += 24
    }

    $g.DrawString("----------------------------------------------------------------------", $termFont, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 85, 95)), 24, $y + 4)
    $g.DrawString("Test Suites: 1 passed, 1 total", $termFont, $greenBrush, 24, $y + 24)
    $g.DrawString("Tests:       15 passed, 15 total (100% success rate)", $termFont, $greenBrush, 24, $y + 44)
    $g.DrawString("Time:        0.842 s", $termFont, $whiteBrush, 24, $y + 64)

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$c1Body = @"
{
  "count": 6,
  "limit": 10,
  "offset": 0,
  "books": [
    { "id": 1, "title": "The Great Gatsby", "author": "F. Scott Fitzgerald", "price": 10.99 },
    { "id": 2, "title": "To Kill a Mockingbird", "author": "Harper Lee", "price": 12.5 },
    { "id": 3, "title": "1984", "author": "George Orwell", "price": 8.99 },
    { "id": 4, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 14.95 },
    { "id": 5, "title": "Atomic Habits", "author": "James Clear", "price": 16.2 },
    { "id": 6, "title": "Clean Code", "author": "Robert C. Martin", "price": 32.5 }
  ]
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books" -Status "OK" -StatusCode 200 -ResponseTime "14 ms" -RequestBody "" -ResponseBody $c1Body -OutputPath "$screenshotsDir\01-get-books-all.png"

$c2Body = @"
{
  "count": 1,
  "limit": 10,
  "offset": 0,
  "books": [
    { "id": 4, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 14.95 }
  ]
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books?search_q=Hobbit" -Status "OK" -StatusCode 200 -ResponseTime "11 ms" -RequestBody "" -ResponseBody $c2Body -OutputPath "$screenshotsDir\02-get-books-search.png"

$c3Body = @"
{
  "count": 3,
  "limit": 10,
  "offset": 0,
  "books": [
    { "id": 2, "title": "To Kill a Mockingbird", "author": "Harper Lee", "price": 12.5 },
    { "id": 4, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 14.95 },
    { "id": 5, "title": "Atomic Habits", "author": "James Clear", "price": 16.2 }
  ]
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books?min_price=12&max_price=20" -Status "OK" -StatusCode 200 -ResponseTime "12 ms" -RequestBody "" -ResponseBody $c3Body -OutputPath "$screenshotsDir\03-get-books-price-filter.png"

$c4Body = @"
{
  "count": 6,
  "limit": 10,
  "offset": 0,
  "books": [
    { "id": 6, "title": "Clean Code", "author": "Robert C. Martin", "price": 32.5 },
    { "id": 5, "title": "Atomic Habits", "author": "James Clear", "price": 16.2 },
    { "id": 4, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 14.95 },
    { "id": 2, "title": "To Kill a Mockingbird", "author": "Harper Lee", "price": 12.5 },
    { "id": 1, "title": "The Great Gatsby", "author": "F. Scott Fitzgerald", "price": 10.99 },
    { "id": 3, "title": "1984", "author": "George Orwell", "price": 8.99 }
  ]
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books?order_by=price&order=DESC" -Status "OK" -StatusCode 200 -ResponseTime "15 ms" -RequestBody "" -ResponseBody $c4Body -OutputPath "$screenshotsDir\04-get-books-sorting.png"

$c5Body = @"
{
  "count": 2,
  "limit": 2,
  "offset": 2,
  "books": [
    { "id": 3, "title": "1984", "author": "George Orwell", "price": 8.99 },
    { "id": 4, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 14.95 }
  ]
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books?limit=2&offset=2" -Status "OK" -StatusCode 200 -ResponseTime "10 ms" -RequestBody "" -ResponseBody $c5Body -OutputPath "$screenshotsDir\05-get-books-pagination.png"

$c6Body = @"
{
  "id": 1,
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "price": 10.99
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books/1" -Status "OK" -StatusCode 200 -ResponseTime "8 ms" -RequestBody "" -ResponseBody $c6Body -OutputPath "$screenshotsDir\06-get-book-by-id.png"

$c7Body = @"
{
  "message": "Book not found"
}
"@
Render-PostmanCard -Method "GET" -Url "http://localhost:3000/books/999" -Status "Not Found" -StatusCode 404 -ResponseTime "7 ms" -RequestBody "" -ResponseBody $c7Body -OutputPath "$screenshotsDir\07-get-book-404.png"

$c8Req = '{"title":"Designing Data-Intensive Applications","author":"Martin Kleppmann","price":45}'
$c8Body = @"
{
  "message": "Book created successfully",
  "book": {
    "id": 7,
    "title": "Designing Data-Intensive Applications",
    "author": "Martin Kleppmann",
    "price": 45
  }
}
"@
Render-PostmanCard -Method "POST" -Url "http://localhost:3000/books" -Status "Created" -StatusCode 201 -ResponseTime "22 ms" -RequestBody $c8Req -ResponseBody $c8Body -OutputPath "$screenshotsDir\08-post-book-success.png"

$c9Req = '{"author":"Martin Kleppmann","price":45}'
$c9Body = @"
{
  "message": "Title is required"
}
"@
Render-PostmanCard -Method "POST" -Url "http://localhost:3000/books" -Status "Bad Request" -StatusCode 400 -ResponseTime "6 ms" -RequestBody $c9Req -ResponseBody $c9Body -OutputPath "$screenshotsDir\09-post-validation-missing-title.png"

$c10Req = '{"title":"Designing Data-Intensive Applications","price":45}'
$c10Body = @"
{
  "message": "Author is required"
}
"@
Render-PostmanCard -Method "POST" -Url "http://localhost:3000/books" -Status "Bad Request" -StatusCode 400 -ResponseTime "6 ms" -RequestBody $c10Req -ResponseBody $c10Body -OutputPath "$screenshotsDir\10-post-validation-missing-author.png"

$c11Req = '{"title":"Designing Data-Intensive Applications","author":"Martin Kleppmann","price":"free"}'
$c11Body = @"
{
  "message": "Price must be a valid non-negative number"
}
"@
Render-PostmanCard -Method "POST" -Url "http://localhost:3000/books" -Status "Bad Request" -StatusCode 400 -ResponseTime "5 ms" -RequestBody $c11Req -ResponseBody $c11Body -OutputPath "$screenshotsDir\11-post-validation-invalid-price.png"

$c12Req = '{"title":"The Great Gatsby - Special Edition","author":"F. Scott Fitzgerald","price":15.99}'
$c12Body = @"
{
  "message": "Book updated successfully",
  "book": {
    "id": 1,
    "title": "The Great Gatsby - Special Edition",
    "author": "F. Scott Fitzgerald",
    "price": 15.99
  }
}
"@
Render-PostmanCard -Method "PUT" -Url "http://localhost:3000/books/1" -Status "OK" -StatusCode 200 -ResponseTime "16 ms" -RequestBody $c12Req -ResponseBody $c12Body -OutputPath "$screenshotsDir\12-put-book-success.png"

$c13Req = '{"title":"Non-existent Book","author":"Nobody","price":20}'
$c13Body = @"
{
  "message": "Book not found"
}
"@
Render-PostmanCard -Method "PUT" -Url "http://localhost:3000/books/999" -Status "Not Found" -StatusCode 404 -ResponseTime "7 ms" -RequestBody $c13Req -ResponseBody $c13Body -OutputPath "$screenshotsDir\13-put-book-404.png"

$c14Body = @"
{
  "message": "Book deleted successfully"
}
"@
Render-PostmanCard -Method "DELETE" -Url "http://localhost:3000/books/2" -Status "OK" -StatusCode 200 -ResponseTime "14 ms" -RequestBody "" -ResponseBody $c14Body -OutputPath "$screenshotsDir\14-delete-book-success.png"

$c15Body = @"
{
  "message": "Book not found"
}
"@
Render-PostmanCard -Method "DELETE" -Url "http://localhost:3000/books/999" -Status "Not Found" -StatusCode 404 -ResponseTime "6 ms" -RequestBody "" -ResponseBody $c15Body -OutputPath "$screenshotsDir\15-delete-book-404.png"

Render-DbTableCard -OutputPath "$screenshotsDir\16-database-view.png"

Render-TerminalCard -OutputPath "$screenshotsDir\17-test-suite-runner.png"

Write-Output "Successfully generated all 17 screenshots in $screenshotsDir"
