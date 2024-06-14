$strZVMIP = "10.213.17.13"
$strZVMPort = "9669" # Usually TCP:9669
$username = "marcelo.santos@br.clara.net" # Zerto username
$password = "W12kstd%" # Zerto password

# Allow self-signed certificates
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$progressPreference = "silentlyContinue"

# Authentication - Get a session token
$authURL = "https://analytics.api.zerto.com/v2/auth/token"
$authBody = @{
    username = $username
    password = $password
} | ConvertTo-Json -Compress

$authHeaders = @{
    "accept" = "application/json"
    "Content-Type" = "application/json"
}

try {
    $authResponse = Invoke-RestMethod -Uri $authURL -Method Post -Body $authBody -Headers $authHeaders
    $token = $authResponse.token
} catch {
    Write-Error "Failed to obtain authentication token. Error: $_"
    exit
}

# Ensure the token was obtained
if (-not $token) {
    Write-Error "Failed to obtain authentication token."
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
}

$ITEM = [string]$args[0]
$VpgIdentifier = [string]$args[1]

switch ($ITEM) {
    "Discovery" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $VPGs = $data.VPGIdentifier
        $count = $VPGs.count
        $JSON = '{"data": [{ '

        foreach ($VpgIdentifier in $VPGs) {
            $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
            $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
            $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
            $JSON += '"{#VPGIDENTIFIER}": "' + $VpgIdentifier + '",'
            $JSON += '"{#VPGNAME}": "' + $data.VPGName + '"'
            if ($count -eq 1) {
                $JSON += '}]}'
            } else {
                $JSON += '},{'
                $count--
            }
        }
        $JSON
    }
    "VPGName" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.VPGName
    }
    "SourceSite" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.SourceSite
    }
    "TargetSite" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.TargetSite
    }
    "UsedStorageInMB" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data = $data.UsedStorageInMB
        $data *= 1000000
        $data
    }
    "VmsCount" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.VmsCount
    }
    "LastTest" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $unixEpochStart = [DateTime]::new(1970,1,1,0,0,0, [DateTimeKind]::Utc)
        [int]($data.LastTest - $unixEpochStart).TotalSeconds
    }
    "ActualRPO" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.ActualRPO
    }
    "Status" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.Status
    }
    "SubStatus" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data = $data | where {$_.VpgIdentifier -eq $VpgIdentifier}
        $data.SubStatus
    }
    "RawVPGData" {
        $vpgListApiUrl = "https://$strZVMIP:$strZVMPort/v1/vpgs"
        $data = Invoke-RestMethod -Uri $vpgListApiUrl -Headers $headers
        $data
    }
}
