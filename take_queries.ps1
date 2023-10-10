param (
    [Parameter(Mandatory = $false)] [string] $pat,
    [Parameter(Mandatory = $false)] [string] $buildsourceversion
)

$folderPath = "/sqlscript/"
$tablePrefixes = @("scpt_dim") # list of sql script table prefixes here
$viewPrefix = "scpt_v_"

$organization = "org-name"
$project = "prj-name"
$repoId = "repo-name"
$branchName = "main"
$baseUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId"

$base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))
$authorizationHeader = @{ Authorization = "Basic $base64Auth" }
$commitUrl = "$baseUrl/commits/$buildsourceversion/changes?api-version=6.1-preview.1"
$response = Invoke-RestMethod -Uri $commitUrl -Headers $authorizationHeader -Method Get

if ($response) {
    foreach ($change in $response.changes) {
        $filePath = $change.item.path

        if ($change.item.gitObjectType -eq "blob" -and $filePath -like "$folderPath*") {
            $fileUrl = "$baseUrl/items?path=$filePath&versionDescriptor.versionType=commit&versionDescriptor.version=$buildsourceversion&recursionLevel=None&api-version=7.0"
            $fileResponse = Invoke-RestMethod -Uri $fileUrl -Headers $authorizationHeader -Method Get

            if ($fileResponse) {
                $fileName = $fileResponse.name
                Write-Host "File name: $fileName"

                $query = $fileResponse.properties.content.query
                Write-Host "Query: $query"

                # Check if the file corresponds to a table or view based on its prefix
                if ($tablePrefixes | ForEach-Object { $filePath -like "$folderPath$_*" }) {
                    # Execute the SQL query for tables
                    $clientid = $env:clientid
                    $tenantid = $env:tenantid
                    $secret = $env:secret

                    $requestBody = @{
                        resource = "https://database.windows.net/"
                        grant_type = "client_credentials"
                        client_id = $clientid
                        client_secret = $secret
                    }

                    $accessTokenResponse = Invoke-RestMethod -Method POST `
                        -Uri "https://login.microsoftonline.com/$tenantid/oauth2/token" `
                        -Body $requestBody `
                        -ContentType "application/x-www-form-urlencoded"

                    $access_token = $accessTokenResponse.access_token

                    # Execute the SQL query for tables
                    Invoke-Sqlcmd -ServerInstance "syn-prd-url-here" `
                        -Database "db-prd-name-here" `
                        -AccessToken $access_token `
                        -query $query

                } elseif ($filePath -like "$folderPath$viewPrefix*") {
                    # Execute the SQL query for views
                    $clientid = $env:clientid
                    $tenantid = $env:tenantid
                    $secret = $env:secret

                    $requestBody = @{
                        resource = "https://database.windows.net/"
                        grant_type = "client_credentials"
                        client_id = $clientid
                        client_secret = $secret
                    }

                    $accessTokenResponse = Invoke-RestMethod -Method POST `
                        -Uri "https://login.microsoftonline.com/$tenantid/oauth2/token" `
                        -Body $requestBody `
                        -ContentType "application/x-www-form-urlencoded"

                    $access_token = $accessTokenResponse.access_token

                    # Execute the SQL query for views
                    Invoke-Sqlcmd -ServerInstance "syn-prd-url-here" `
                        -Database "db-prd-name-here" `
                        -AccessToken $access_token `
                        -query $query
                } else {
                    Write-Host "File does not match any expected prefix."
                }
            }
        }
    }
} else {
    Write-Host "Branch '$branchName' not found in the repository."
}