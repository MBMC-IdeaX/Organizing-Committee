$body = @{ username = 'admin'; password = 'IdeaXAdmin2026!' } | ConvertTo-Json
$loginRes = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body $body -ContentType 'application/json'
Write-Host "Login Status:" $loginRes.success
$token = $loginRes.data.token

try {
    $dash = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/dashboard/summary' -Method Get -Headers @{ Authorization = "Bearer $token" }
    Write-Host "Dashboard Response:"
    $dash | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Error calling dashboard:" $_.Exception.Message
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host "Response Body:" $reader.ReadToEnd()
    }
}
