$body = @{ username = 'admin'; password = 'IdeaXAdmin2026!' } | ConvertTo-Json
$loginRes = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body $body -ContentType 'application/json'
$token = $loginRes.data.token
$headers = @{ Authorization = "Bearer $token" }

Write-Host "Creating Teams..."
$t1 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/teams' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ teamName = 'Team Alpha'; projectName = 'Smart Waste'; idea = 'IoT sensor waste monitoring'; displayOrder = 1 } | ConvertTo-Json)
$t2 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/teams' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ teamName = 'Team Nova'; projectName = 'AgriBuddy'; idea = 'AI automated soil and crop analysis'; displayOrder = 2 } | ConvertTo-Json)
$t3 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/teams' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ teamName = 'Team Vision'; projectName = 'HealthAI'; idea = 'Computer vision diagnostics'; displayOrder = 3 } | ConvertTo-Json)

Write-Host "Creating Criteria..."
$c1 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/criteria' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ name = 'Innovation'; description = 'Originality and novelty'; maxScore = 20; displayOrder = 1 } | ConvertTo-Json)
$c2 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/criteria' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ name = 'Technical Implementation'; description = 'Architecture and execution'; maxScore = 20; displayOrder = 2 } | ConvertTo-Json)
$c3 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/criteria' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ name = 'Impact & Feasibility'; description = 'Practical utility'; maxScore = 20; displayOrder = 3 } | ConvertTo-Json)

Write-Host "Creating Judges..."
try {
    $j1 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/judges' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ username = 'judge1'; password = 'JudgePassword123!' } | ConvertTo-Json)
} catch { Write-Host "Judge 1 may already exist" }
try {
    $j2 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/judges' -Method Post -Headers $headers -ContentType 'application/json' -Body (@{ username = 'judge2'; password = 'JudgePassword123!' } | ConvertTo-Json)
} catch { Write-Host "Judge 2 may already exist" }

Write-Host "`nFetching Updated Dashboard Summary:"
$dash = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/admin/dashboard/summary' -Method Get -Headers $headers
$dash.data | ConvertTo-Json
