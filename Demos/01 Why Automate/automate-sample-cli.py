import subprocess

# ============================================================
# Config - Update before running
# ============================================================
CAPACITY_NAME   = "<your-capacity-name>"
WORKSPACE_NAME  = "Fabric CLI - Python"
PRINCIPAL_ID    = "<your-principal-id>"
ROLE            = "member"
NOTEBOOK_NAME   = "Rebrickable - Ingest"
NOTEBOOK_SOURCE = "Demos/Resources/Rebrickable - Ingest.Notebook"
# ============================================================

WORKSPACE = f"{WORKSPACE_NAME}.Workspace"

def fab(*args):
    print(f"$ fab {' '.join(args)}")
    subprocess.run(["fab", *args], check=True)

# 0. Login
# Manually run fab auth login prior to running the scripts

# 1. Create workspace (assign capacity by name)
fab("mkdir", WORKSPACE, "-P", f"capacityName={CAPACITY_NAME}")

# 2. Assign user/group as Workspace Member
fab("acl", "set", WORKSPACE, "-I", PRINCIPAL_ID, "-R", ROLE, "--force")

# 3. Create the three lakehouses (landing, base, curated)
fab("mkdir", f"{WORKSPACE}/Landing.Lakehouse")
fab("mkdir", f"{WORKSPACE}/Base.Lakehouse")
fab("mkdir", f"{WORKSPACE}/Curated.Lakehouse")

# 4. Import the Rebrickable notebook from local .ipynb
fab("import", f"{WORKSPACE}/{NOTEBOOK_NAME}.Notebook",
    "-i", NOTEBOOK_SOURCE, "--format", ".ipynb", "--force")
