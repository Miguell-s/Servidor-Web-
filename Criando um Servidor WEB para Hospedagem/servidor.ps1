# Servidor HTTP Simples em PowerShell
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

Write-Host "Servidor rodando em http://localhost:8000" -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $url = $request.Url.LocalPath
        if ($url -eq "/") { $url = "/index.html" }
        
        $filePath = Join-Path $PSScriptRoot $url.TrimStart("/")
        
        if (Test-Path $filePath) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            
            if ($url -match "\.css$") { $response.ContentType = "text/css" }
            elseif ($url -match "\.js$") { $response.ContentType = "application/javascript" }
            else { $response.ContentType = "text/html" }
            
            Write-Host "200 OK: $url" -ForegroundColor Green
        } else {
            $response.StatusCode = 404
            $message = [System.Text.Encoding]::UTF8.GetBytes("404 - Arquivo nao encontrado")
            $response.OutputStream.Write($message, 0, $message.Length)
            Write-Host "404 NOT FOUND: $url" -ForegroundColor Red
        }
        
        $response.Close()
    }
} finally {
    $listener.Stop()
    Write-Host "Servidor parado" -ForegroundColor Red
}
