#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Config - Update before running
# ============================================================
CAPACITY_NAME="<your-capacity-name>"
WORKSPACE_NAME="Fabric CLI - Bash"
PRINCIPAL_ID="<your-principal-id>"
ROLE="admin"
NOTEBOOK_NAME="Rebrickable - Ingest"
NOTEBOOK_SOURCE="Demos/Resources/Rebrickable - Ingest.Notebook"
# ============================================================

WORKSPACE="$WORKSPACE_NAME.Workspace"

run() { echo "\$ fab $*"; fab "$@"; }

# 0. Login
# Manually run fab auth login prior to running the scripts

# 1. Create workspace (assign capacity by name)
run mkdir "$WORKSPACE" -P "capacityName=$CAPACITY_NAME"

# 2. Assign user/group as Workspace Member
run acl set "$WORKSPACE" -I "$PRINCIPAL_ID" -R "$ROLE" --force

# 3. Create the three lakehouses (landing, base, curated)
run mkdir "$WORKSPACE/Landing.Lakehouse"
run mkdir "$WORKSPACE/Base.Lakehouse"
run mkdir "$WORKSPACE/Curated.Lakehouse"

# 4. Import the Rebrickable notebook from local .ipynb
run import "$WORKSPACE/$NOTEBOOK_NAME.Notebook" -i "$NOTEBOOK_SOURCE" --format .ipynb --force