# ============================================================
# Config - Update before running
# ============================================================
$CapacityName   = "<your-capacity-name>"
$WorkspaceName  = "Fabric CLI - PowerShell"
$PrincipalId    = "<your-principal-id>"
$Role           = "admin"
$NotebookName   = "Rebrickable - Ingest"
$NotebookSource = "Demos/Resources/Rebrickable - Ingest.Notebook"
# ============================================================

$ErrorActionPreference = "Stop"
$Workspace = "$WorkspaceName.Workspace"

function Invoke-Fab {
    Write-Host "$ fab $args"
    & fab @args
    if ($LASTEXITCODE -ne 0) { throw "fab command failed (exit $LASTEXITCODE)" }
}
 
# 0. Login
# Manually run fab auth login prior to running the scripts

# 1. Create workspace (assign capacity by name)
Invoke-Fab mkdir "$Workspace" -P "capacityName=$CapacityName"

# 2. Assign user/group as Workspace Member
Invoke-Fab acl set "$Workspace" -I $PrincipalId -R $Role --force

# 3. Create the three lakehouses (landing, base, curated)
Invoke-Fab mkdir "$Workspace/Landing.Lakehouse"
Invoke-Fab mkdir "$Workspace/Base.Lakehouse"
Invoke-Fab mkdir "$Workspace/Curated.Lakehouse"

# 4. Import the Rebrickable notebook from local .ipynb
Invoke-Fab import "$Workspace/$NotebookName.Notebook" -i "$NotebookSource" --format .ipynb --force