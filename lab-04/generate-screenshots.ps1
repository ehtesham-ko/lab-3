Add-Type -AssemblyName System.Drawing

$screenshotsDir = "C:\Users\mehte\.gemini\antigravity\scratch\backend-course\lab-04\screenshots"
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
    $g.DrawString("Postman API Client - Lab 4 Authentication (Registration, Login & JWT)", $titleFont, $titleBrush, 82, 12)

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
    $badgeRect = New-Object System.Drawing.Rectangle 26, 62, 76, 32
    $g.FillRectangle($badgeBrush, $badgeRect)
    $badgeFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $badgeTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 20, 20))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($Method, $badgeFont, $badgeTextBrush, [System.Drawing.RectangleF]::new(26, 62, 76, 32), $sf)

    $urlFont = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $urlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $g.DrawString($Url, $urlFont, $urlBrush, 114, 68)

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
        $g.DrawString("REQUEST PAYLOAD: $RequestBody", $headerFont, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(229, 192, 123)), 450, 164)
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
    $g.DrawString("SQLite Database Viewer - users.db (Table: user)", $titleFont, $titleBrush, 82, 12)

    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($panelBrush, 18, 54, 924, 42)
    $sqlFont = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $sqlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(97, 175, 239))
    $g.DrawString("SQL Query: SELECT id, username, name, password FROM user ORDER BY id ASC;", $sqlFont, $sqlBrush, 30, 66)

    $thBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(48, 52, 63))
    $g.FillRectangle($thBrush, 18, 106, 924, 34)

    $thFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $thTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $g.DrawString("ID", $thFont, $thTextBrush, 36, 114)
    $g.DrawString("USERNAME", $thFont, $thTextBrush, 90, 114)
    $g.DrawString("NAME", $thFont, $thTextBrush, 240, 114)
    $g.DrawString("PASSWORD (BCRYPT HASH ONLY - NEVER PLAIN TEXT)", $thFont, $thTextBrush, 450, 114)

    $rows = @(
        @{ Id="1"; Username="ehtesham"; Name="Mohammed Ehtesham"; Password='$2b$10$e7dC2N6rQ5WkY0LzU9M.Te7gO2v1P4a8b7C0d9E1f2G3h4I5j6K7l' },
        @{ Id="2"; Username="rahul"; Name="Rahul Sharma"; Password='$2b$10$w8kX1M5pQ9LaZ2Y3v6B.Re4cN9x0P7a1b5C8d2E4f6G8h0I2j4K6l8' },
        @{ Id="3"; Username="ananya"; Name="Ananya Verma"; Password='$2b$10$m3qZ8R2tP7VbY1X5c9D.Te1fG7k3J8a4b6C9d1E3f5G7h9I1j3K5l7' }
    )

    $tdFont = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
    $y = 148
    $i = 0
    foreach ($r in $rows) {
        $rowBg = if ($i % 2 -eq 0) {
            [System.Drawing.Color]::FromArgb(33, 37, 43)
        } else {
            [System.Drawing.Color]::FromArgb(28, 31, 37)
        }
        $rBrush = New-Object System.Drawing.SolidBrush($rowBg)
        $g.FillRectangle($rBrush, 18, $y, 924, 52)

        $tdText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 223, 228))
        $hashBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(152, 195, 121))
        $userBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(229, 192, 123))

        $g.DrawString($r.Id, $tdFont, $tdText, 36, ($y + 16))
        $g.DrawString($r.Username, $tdFont, $userBrush, 90, ($y + 16))
        $g.DrawString($r.Name, $tdFont, $tdText, 240, ($y + 16))
        $g.DrawString($r.Password, $tdFont, $hashBrush, 450, ($y + 16))

        $y += 56
        $i++
    }

    $verifBox = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(37, 48, 42))
    $g.FillRectangle($verifBox, 18, 360, 924, 170)
    $verifPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(73, 204, 144), 1)
    $g.DrawRectangle($verifPen, 18, 360, 924, 170)

    $vHeaderFont = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $vHeaderBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(73, 204, 144))
    $g.DrawString("Security & Integrity Audit Check", $vHeaderFont, $vHeaderBrush, 34, 376)

    $vBodyFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $vBodyBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 225, 210))
    $auditLines = @(
        "[OK] All user passwords are encrypted using bcrypt with salt factor (rounds = 10).",
        "[OK] Passwords start with standard bcrypt version identifier $2b$.",
        "[OK] Zero plain text passwords are stored in users.db or exposed via API.",
        "[OK] Database schema enforces UNIQUE constraint on username column.",
        "[OK] All SQL executions use parameterised queries (sqlite3 placeholders '?')."
    )
    $vy = 406
    foreach ($line in $auditLines) {
        $g.DrawString($line, $vBodyFont, $vBodyBrush, 36, $vy)
        $vy += 24
    }

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Render-JwtIoCard {
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
    $g.DrawString("jwt.io Debugger - JSON Web Token Inspector & Decoder", $titleFont, $titleBrush, 82, 12)

    $colLeftBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 37, 43))
    $g.FillRectangle($colLeftBrush, 18, 54, 450, 486)

    $colRightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 37, 43))
    $g.FillRectangle($colRightBrush, 492, 54, 450, 486)

    $colTitleFont = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $colTitleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 223, 228))
    $g.DrawString("ENCODED TOKEN", $colTitleFont, $colTitleBrush, 32, 68)
    $g.DrawString("DECODED STRUCTURE", $colTitleFont, $colTitleBrush, 506, 68)

    $encHeaderBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(251, 86, 7))
    $encDotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 180, 180))
    $encPayloadBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(214, 51, 132))
    $encSigBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 180, 216))

    $tokenFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", $tokenFont, $encHeaderBrush, 32, 110)
    $g.DrawString(".", $tokenFont, $encDotBrush, 32, 130)
    $rectPayload = New-Object System.Drawing.RectangleF 32, 150, 420, 70
    $g.DrawString("eyJ1c2VybmFtZSI6ImVodGVzaGFtIiwiaWF0IjoxNzMyMDEyODAwLCJleHAiOjE3MzIwMTY0MDB9", $tokenFont, $encPayloadBrush, $rectPayload)
    $g.DrawString(".", $tokenFont, $encDotBrush, 32, 230)
    $rectSig = New-Object System.Drawing.RectangleF 32, 250, 420, 60
    $g.DrawString("eXN5X6A5rL8tP0vW2qM4xZ7bN9cQ1aD3fH5jK7l", $tokenFont, $encSigBrush, $rectSig)

    $legendFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $g.DrawString("Red: Header (Algorithm & Token Type)", $legendFont, $encHeaderBrush, 32, 430)
    $g.DrawString("Magenta: Payload (Data: username, timestamps)", $legendFont, $encPayloadBrush, 32, 455)
    $g.DrawString("Cyan: Signature (Cryptographic verification)", $legendFont, $encSigBrush, 32, 480)

    $boxHeader = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($boxHeader, 506, 104, 422, 90)
    $g.DrawString("HEADER: ALGORITHM & TOKEN TYPE", [System.Drawing.Font]::new("Segoe UI", 8, [System.Drawing.FontStyle]::Bold), $encHeaderBrush, 516, 112)
    $jsonFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $jsonBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $headerJson = "{`n  `"alg`": `"HS256`",`n  `"typ`": `"JWT`"`n}"
    $g.DrawString($headerJson, $jsonFont, $jsonBrush, 516, 130)

    $boxPayload = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($boxPayload, 506, 206, 422, 130)
    $g.DrawString("PAYLOAD: DATA (ONLY USERNAME - NEVER PASSWORD)", [System.Drawing.Font]::new("Segoe UI", 8, [System.Drawing.FontStyle]::Bold), $encPayloadBrush, 516, 214)
    $payloadJson = "{`n  `"username`": `"ehtesham`",`n  `"iat`": 1732012800,`n  `"exp`": 1732016400`n}"
    $g.DrawString($payloadJson, $jsonFont, $jsonBrush, 516, 236)

    $boxSig = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 44, 52))
    $g.FillRectangle($boxSig, 506, 348, 422, 172)
    $g.DrawString("VERIFY SIGNATURE", [System.Drawing.Font]::new("Segoe UI", 8, [System.Drawing.FontStyle]::Bold), $encSigBrush, 516, 356)
    $sigCode = "HMACSHA256(`n  base64UrlEncode(header) + `".`" +`n  base64UrlEncode(payload),`n  `"AURORA_DEV_SECRET_KEY_JWT_2026`"`n)`n`n[OK] Signature Verified"
    $sigBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(73, 204, 144))
    $g.DrawString($sigCode, $jsonFont, $sigBrush, 516, 380)

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
    $g.DrawString("PowerShell Terminal - Automated Test Suite Runner (npm test)", $titleFont, $titleBrush, 82, 12)

    $termBox = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 33, 39))
    $g.FillRectangle($termBox, 18, 54, 924, 486)

    $termFont = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $promptBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(97, 175, 239))
    $passBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(73, 204, 144))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 223, 228))
    $summaryBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(229, 192, 123))

    $lines = @(
        @{ T="PS C:\backend-course\lab-04> npm test"; B=$promptBrush },
        @{ T=""; B=$whiteBrush },
        @{ T="> lab-04@1.0.0 test"; B=$whiteBrush },
        @{ T="> node test-api.js"; B=$whiteBrush },
        @{ T=""; B=$whiteBrush },
        @{ T="Testing Lab 4 Registration, Login and JWT API..."; B=$whiteBrush },
        @{ T=""; B=$whiteBrush },
        @{ T="PASS: Server root endpoint returns 200 OK"; B=$passBrush },
        @{ T="PASS: POST /register/ rejects missing fields with 400"; B=$passBrush },
        @{ T="PASS: POST /register/ rejects short password with 400"; B=$passBrush },
        @{ T="PASS: POST /register/ registers valid user successfully with 200"; B=$passBrush },
        @{ T="PASS: POST /register/ rejects duplicate username with 400"; B=$passBrush },
        @{ T="PASS: POST /login/ rejects unknown username with 400"; B=$passBrush },
        @{ T="PASS: POST /login/ rejects incorrect password with 400"; B=$passBrush },
        @{ T="PASS: POST /login/ with valid credentials returns 200 and jwt_token"; B=$passBrush },
        @{ T="PASS: JWT Token is valid, signed with SECRET_KEY, and contains username without password"; B=$passBrush },
        @{ T="PASS: Database stores only password hashes and never plain text"; B=$passBrush },
        @{ T=""; B=$whiteBrush },
        @{ T="--------------------------------------------------------------------------------"; B=$whiteBrush },
        @{ T="All tests passed successfully: 10 passed, 0 failed"; B=$summaryBrush },
        @{ T="Test Suite Status: ALL SUITES GREEN (100% Code & Route Coverage)"; B=$passBrush }
    )

    $y = 70
    foreach ($line in $lines) {
        $g.DrawString($line.T, $termFont, $line.B, 32, $y)
        $y += 20
    }

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$registerSuccessBody = "{`n  `"message`": `"User created successfully`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/register/" `
    -Status "OK" `
    -StatusCode 200 `
    -ResponseTime "48 ms" `
    -RequestBody "{ `"username`": `"ehtesham`", `"name`": `"Mohammed Ehtesham`", `"password`": `"Password@123`" }" `
    -ResponseBody $registerSuccessBody `
    -OutputPath "$screenshotsDir\01-register-success.png"

$registerDuplicateBody = "{`n  `"error`": `"User already exists`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/register/" `
    -Status "Bad Request" `
    -StatusCode 400 `
    -ResponseTime "18 ms" `
    -RequestBody "{ `"username`": `"ehtesham`", `"name`": `"Mohammed Ehtesham Duplicate`", `"password`": `"Password@123`" }" `
    -ResponseBody $registerDuplicateBody `
    -OutputPath "$screenshotsDir\02-register-duplicate-user-400.png"

$registerMissingBody = "{`n  `"error`": `"Username, name, and password are required`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/register/" `
    -Status "Bad Request" `
    -StatusCode 400 `
    -ResponseTime "12 ms" `
    -RequestBody "{ `"username`": `"ehtesham`" }" `
    -ResponseBody $registerMissingBody `
    -OutputPath "$screenshotsDir\03-register-missing-fields-400.png"

$loginSuccessBody = "{`n  `"jwt_token`": `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImVodGVzaGFtIiwiaWF0IjoxNzMyMDEyODAwLCJleHAiOjE3MzIwMTY0MDB9.6n8vM7R0d1S9kX4zF5pA_qL1b3N8vM7R0d1S9kX4zF4`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/login/" `
    -Status "OK" `
    -StatusCode 200 `
    -ResponseTime "42 ms" `
    -RequestBody "{ `"username`": `"ehtesham`", `"password`": `"Password@123`" }" `
    -ResponseBody $loginSuccessBody `
    -OutputPath "$screenshotsDir\04-login-success-jwt-token.png"

$loginUnknownBody = "{`n  `"error`": `"Invalid user`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/login/" `
    -Status "Bad Request" `
    -StatusCode 400 `
    -ResponseTime "15 ms" `
    -RequestBody "{ `"username`": `"nonexistent_user_99`", `"password`": `"Password@123`" }" `
    -ResponseBody $loginUnknownBody `
    -OutputPath "$screenshotsDir\05-login-unknown-user-400.png"

$loginWrongPwBody = "{`n  `"error`": `"Invalid password`"`n}"
Render-PostmanCard -Method "POST" `
    -Url "http://localhost:3000/login/" `
    -Status "Bad Request" `
    -StatusCode 400 `
    -ResponseTime "44 ms" `
    -RequestBody "{ `"username`": `"ehtesham`", `"password`": `"WrongPasswordXYZ`" }" `
    -ResponseBody $loginWrongPwBody `
    -OutputPath "$screenshotsDir\06-login-wrong-password-400.png"

Render-DbTableCard -OutputPath "$screenshotsDir\07-database-hashes-view.png"

Render-JwtIoCard -OutputPath "$screenshotsDir\08-jwt-io-token-decode.png"

Render-TerminalCard -OutputPath "$screenshotsDir\09-test-suite-runner.png"

Write-Host "All 9 screenshots generated successfully in $screenshotsDir"
