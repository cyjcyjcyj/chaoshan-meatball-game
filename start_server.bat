@echo off
cd /d "%~dp0"
echo Starting HTTP server on port 8000...
echo Serving files from: %~dp0
echo.
echo Press Ctrl+C to stop the server.
echo.
powershell -ExecutionPolicy Bypass -Command "$listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://0.0.0.0:8000/'); $listener.Prefixes.Add('http://localhost:8000/'); $listener.Start(); Write-Host 'Server running at http://localhost:8000/'; while ($listener.IsListening) { $context = $listener.GetContext(); $request = $context.Request; $response = $context.Response; $url = $request.Url.LocalPath; if ($url -eq '/') { $url = '/index.html' }; $filePath = Join-Path '%~dp0' $url.TrimStart('/'); if (Test-Path $filePath) { $content = [System.IO.File]::ReadAllBytes($filePath); $ext = [System.IO.Path]::GetExtension($filePath).ToLower(); $contentType = 'text/html'; if ($ext -eq '.js') { $contentType = 'text/javascript' } elseif ($ext -eq '.css') { $contentType = 'text/css' }; $response.ContentType = $contentType; $response.ContentLength64 = $content.Length; $response.OutputStream.Write($content, 0, $content.Length) } else { $response.StatusCode = 404 }; $response.Close() }"