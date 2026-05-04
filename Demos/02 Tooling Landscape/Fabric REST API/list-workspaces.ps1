# List Microsoft Fabric workspaces using the Fabric REST API.
#
# Supports two authentication modes:
#   - INTERACTIVE: Browser-based sign-in (user identity)
#   - SPN: Service Principal (client ID + secret)
#
# Prerequisites:
#   Install-Module -Name Az.Accounts -Scope CurrentUser

# ----------------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------------
$AuthMode = "INTERACTIVE"   # "INTERACTIVE" or "SPN"

# Fill these in when using SPN authentication
$TenantId     = "<your-tenant-id>"
$ClientId     = "<your-client-id>"
$ClientSecret = "<your-client-secret>"

$FabricScope   = "https://api.fabric.microsoft.com/.default"
$WorkspacesUrl = "https://api.fabric.microsoft.com/v1/workspaces"

# ----------------------------------------------------------------------------
# AUTHENTICATION
# ----------------------------------------------------------------------------
switch ($AuthMode.ToUpper()) {
    "INTERACTIVE" {
        Connect-AzAccount -WarningAction SilentlyContinue | Out-Null
    }
    "SPN" {
        $securePassword = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($ClientId, $securePassword)
        Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $credential -WarningAction SilentlyContinue | Out-Null
    }
    default {
        throw "Unknown AuthMode '$AuthMode'. Use 'INTERACTIVE' or 'SPN'."
    }
}

$token = (Get-AzAccessToken -ResourceUrl $FabricScope.Replace("/.default", "")).Token

# ----------------------------------------------------------------------------
# LIST WORKSPACES
# ----------------------------------------------------------------------------
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri $WorkspacesUrl -Headers $headers -Method Get

$workspaces = $response.value
Write-Host "Found $($workspaces.Count) workspaces`n"

foreach ($ws in $workspaces) {
    $capacityId = if ($ws.capacityId) { $ws.capacityId } else { "N/A" }
    Write-Host "* $($ws.displayName) (ID: $($ws.id), Capacity ID: $capacityId)"
}
