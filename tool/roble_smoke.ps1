$ErrorActionPreference = 'Continue'
$baseAuth = 'https://roble-api.openlab.uninorte.edu.co/auth/nodo_a9a72e0eab'
$baseDb = 'https://roble-api.openlab.uninorte.edu.co/database/nodo_a9a72e0eab'
$email = "nodo.auto.$(Get-Date -Format 'yyyyMMddHHmmss')@test.local"
$password = 'NodoQA123!'
$name = 'Auto Tester'
$results = New-Object System.Collections.Generic.List[string]

function Ok([string]$msg) {
  $results.Add("[OK] $msg") | Out-Null
  Write-Host "[OK] $msg"
}
function Fail([string]$msg) {
  $results.Add("[FAIL] $msg") | Out-Null
  Write-Host "[FAIL] $msg"
}

try {
  $projects = @(Invoke-RestMethod -Method Get -Uri "$baseDb/public-read?tableName=projects")
  Ok "public-read projects = $($projects.Count)"
} catch {
  Fail "public-read projects: $($_.ErrorDetails.Message)"
}

try {
  Invoke-RestMethod -Method Post -Uri "$baseAuth/signup-direct" -ContentType 'application/json' -Body (@{
      email = $email; password = $password; name = $name
    } | ConvertTo-Json) | Out-Null
  Ok "signup-direct $email"
} catch {
  Fail "signup-direct: $($_.ErrorDetails.Message)"
}

$token = $null
$userId = $null
try {
  $login = Invoke-RestMethod -Method Post -Uri "$baseAuth/login" -ContentType 'application/json' -Body (@{
      email = $email; password = $password
    } | ConvertTo-Json)
  $token = $login.accessToken
  $userId = $login.user.id
  Ok "login userId=$userId"
} catch {
  Fail "login: $($_.ErrorDetails.Message)"
}

if ($token) {
  $h = @{ Authorization = "Bearer $token" }
  foreach ($table in @(
      'projects', 'project_updates', 'users', 'applications', 'user_skills',
      'categories', 'skills', 'project_categories', 'project_skills'
    )) {
    try {
      $rows = @(Invoke-RestMethod -Method Get -Uri "$baseDb/read?tableName=$table" -Headers $h)
      Ok "read $table count=$($rows.Count)"
    } catch {
      Fail "read ${table}: $($_.ErrorDetails.Message)"
    }
  }

  $username = 'auto_' + (Get-Random -Maximum 99999)
  try {
    Invoke-RestMethod -Method Post -Uri "$baseDb/insert-one" -Headers $h -ContentType 'application/json' -Body (@{
        tableName = 'users'
        record = @{
          id = $userId
          username = $username
          name = $name
          bio = 'QA auto'
          created_at = (Get-Date).ToUniversalTime().ToString('o')
        }
      } | ConvertTo-Json -Depth 5) | Out-Null
    Ok 'insert users profile'
  } catch {
    Fail "insert users: $($_.ErrorDetails.Message)"
  }

  $projectId = [guid]::NewGuid().ToString()
  $projectRecordId = $null
  try {
    $p = Invoke-RestMethod -Method Post -Uri "$baseDb/insert-one" -Headers $h -ContentType 'application/json' -Body (@{
        tableName = 'projects'
        record = @{
          id = $projectId
          creator_id = $userId
          title = 'Auto proyecto timeline'
          description = 'Prueba automatica de status y updates'
          total_spots = 4
          filled_spots = 0
          status = 'idea'
          gradient_colors = '["0xFF7B6CF0","0xFFB8A9FF"]'
          created_at = (Get-Date).ToUniversalTime().ToString('o')
        }
      } | ConvertTo-Json -Depth 6)
    $projectRecordId = $p._id
    Ok "insert project status=$($p.status) _id=$projectRecordId"
  } catch {
    Fail "insert project: $($_.ErrorDetails.Message)"
  }

  if ($projectId) {
    try {
      Invoke-RestMethod -Method Post -Uri "$baseDb/insert-one" -Headers $h -ContentType 'application/json' -Body (@{
          tableName = 'project_updates'
          record = @{
            id = [guid]::NewGuid().ToString()
            project_id = $projectId
            author_id = $userId
            author_name = $name
            title = 'Primer avance'
            body = 'Update creado por prueba automatica'
            created_at = (Get-Date).ToUniversalTime().ToString('o')
            status = 'in_progress'
          }
        } | ConvertTo-Json -Depth 6) | Out-Null
      Ok 'insert project_updates'
    } catch {
      Fail "insert project_updates: $($_.ErrorDetails.Message)"
    }

    if ($projectRecordId) {
      try {
        Invoke-RestMethod -Method Put -Uri "$baseDb/update" -Headers $h -ContentType 'application/json' -Body (@{
            tableName = 'projects'
            idColumn = '_id'
            idValue = $projectRecordId
            updates = @{
              status = 'in_progress'
              updated_at = (Get-Date).ToUniversalTime().ToString('o')
            }
          } | ConvertTo-Json -Depth 6) | Out-Null
        Ok 'update projects.status -> in_progress'
      } catch {
        Fail "update status: $($_.ErrorDetails.Message)"
      }
    }

    try {
      Invoke-RestMethod -Method Post -Uri "$baseDb/insert-one" -Headers $h -ContentType 'application/json' -Body (@{
          tableName = 'applications'
          record = @{
            id = [guid]::NewGuid().ToString()
            project_id = $projectId
            applicant_id = $userId
            motivation = 'Quiero aportar'
            experience = 'Flutter'
            status = 'pending'
            submitted_at = (Get-Date).ToUniversalTime().ToString('o')
          }
        } | ConvertTo-Json -Depth 6) | Out-Null
      Ok 'insert applications'
    } catch {
      Fail "insert applications: $($_.ErrorDetails.Message)"
    }

    try {
      $updates = @(Invoke-RestMethod -Method Get -Uri "$baseDb/read?tableName=project_updates&project_id=$projectId" -Headers $h)
      Ok "filter project_updates count=$($updates.Count)"
    } catch {
      Fail "filter updates: $($_.ErrorDetails.Message)"
    }
  }
}

Write-Host ''
Write-Host '==== SUMMARY ===='
$results | ForEach-Object { Write-Host $_ }
$failCount = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
Write-Host "FAILS=$failCount"
if ($failCount -gt 0) { exit 1 } else { exit 0 }
