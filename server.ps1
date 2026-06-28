$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Script directory: $scriptDir"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "Server running at http://localhost:8000/"
Write-Host "Serving files from: $scriptDir"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $url = $request.Url.LocalPath
        Write-Host "Request: $url"
        
        if ($url -eq "/") {
            $url = "/index.html"
        }
        
        $filePath = Join-Path $scriptDir $url.TrimStart("/")
        Write-Host "File path: $filePath"
        
        if (Test-Path $filePath) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = "text/html"
            switch ($ext) {
                ".js" { $contentType = "text/javascript" }
                ".css" { $contentType = "text/css" }
                ".json" { $contentType = "application/json" }
                ".png" { $contentType = "image/png" }
                ".jpg" { $contentType = "image/jpeg" }
                ".gif" { $contentType = "image/gif" }
            }
            
            $response.ContentType = $contentType
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            Write-Host "Served: $filePath ($($content.Length) bytes)"
        } else {
            $response.StatusCode = 404
            Write-Host "Not found: $filePath"
        }
        
        $response.Close()
    } catch {
        Write-Host "Error: $_"
    }
}