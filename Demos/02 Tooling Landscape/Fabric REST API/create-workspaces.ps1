# Create Microsoft Fabric workspaces from a list using the Fabric REST API.
#
# Optionally assigns a security group to each workspace with the configured role.
# If GroupId is empty, role assignments are skipped.
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

# Workspace settings
$CapacityId = "<your-capacity-id>"
$GroupId    = ""            # Security group ID for ACL. Leave empty to skip role assignment.
$Role       = "Member"      # Admin | Member | Contributor | Viewer

# Workspaces to create
$Workspaces = @(
    @{ Name = "WS - Sales";     Description = "Sales analytics workspace" }
    @{ Name = "WS - Marketing"; Description = "Marketing analytics workspace" }
    @{ Name = "WS - Finance";   Description = "Finance analytics workspace" }
)

$FabricResource = "https://api.fabric.microsoft.com"
$WorkspacesUrl  = "$FabricResource/v1/workspaces"

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

$token = (Get-AzAccessToken -ResourceUrl $FabricResource).Token

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# ----------------------------------------------------------------------------
# CREATE WORKSPACES
# ----------------------------------------------------------------------------
foreach ($ws in $Workspaces) {
    $body = @{
        displayName = $ws.Name
        description = $ws.Description
        capacityId  = $CapacityId
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $WorkspacesUrl -Headers $headers -Method Post -Body $body
    $workspaceId = $response.id
    Write-Host "* Created '$($ws.Name)' (ID: $workspaceId)"

    # Assign security group with the configured role (skip if no group provided)
    if ($GroupId) {
        $aclBody = @{
            principal = @{ id = $GroupId; type = "Group" }
            role      = $Role
        } | ConvertTo-Json

        $aclUrl = "$WorkspacesUrl/$workspaceId/roleAssignments"
        Invoke-RestMethod -Uri $aclUrl -Headers $headers -Method Post -Body $aclBody | Out-Null
        Write-Host "  - Assigned group $GroupId as $Role"
    }
}
