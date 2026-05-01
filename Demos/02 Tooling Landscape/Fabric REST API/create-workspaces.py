"""
Create Microsoft Fabric workspaces from a list using the Fabric REST API.

Optionally assigns a security group to each workspace with the configured role.
If GROUP_ID is empty, role assignments are skipped.

Prerequisites:
  pip install azure-identity requests
"""

import requests
from azure.identity import InteractiveBrowserCredential, ClientSecretCredential

# ----------------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------------
AUTH_MODE = "INTERACTIVE"   # "INTERACTIVE" or "SPN"

# Fill these in when using SPN authentication
TENANT_ID     = "<your-tenant-id>"
CLIENT_ID     = "<your-client-id>"
CLIENT_SECRET = "<your-client-secret>"

# Workspace settings
CAPACITY_ID = "<your-capacity-id>"
GROUP_ID    = ""            # Security group ID for ACL. Leave empty to skip role assignment.
ROLE        = "Member"      # Admin | Member | Contributor | Viewer

# Workspaces to create
WORKSPACES = [
    {"name": "WS - Sales",     "description": "Sales analytics workspace"},
    {"name": "WS - Marketing", "description": "Marketing analytics workspace"},
    {"name": "WS - Finance",   "description": "Finance analytics workspace"},
]

FABRIC_SCOPE   = "https://api.fabric.microsoft.com/.default"
WORKSPACES_URL = "https://api.fabric.microsoft.com/v1/workspaces"

# ----------------------------------------------------------------------------
# AUTHENTICATION
# ----------------------------------------------------------------------------
if AUTH_MODE.upper() == "INTERACTIVE":
    credential = InteractiveBrowserCredential()
elif AUTH_MODE.upper() == "SPN":
    credential = ClientSecretCredential(
        tenant_id=TENANT_ID,
        client_id=CLIENT_ID,
        client_secret=CLIENT_SECRET,
    )
else:
    raise ValueError(f"Unknown AUTH_MODE '{AUTH_MODE}'. Use 'INTERACTIVE' or 'SPN'.")

token = credential.get_token(FABRIC_SCOPE).token

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json",
}

# ----------------------------------------------------------------------------
# CREATE WORKSPACES
# ----------------------------------------------------------------------------
for ws in WORKSPACES:
    body = {
        "displayName": ws["name"],
        "description": ws["description"],
        "capacityId":  CAPACITY_ID,
    }

    response = requests.post(WORKSPACES_URL, headers=headers, json=body)
    response.raise_for_status()

    workspace_id = response.json()["id"]
    print(f"* Created '{ws['name']}' (ID: {workspace_id})")

    # Assign security group with the configured role (skip if no group provided)
    if GROUP_ID:
        acl_body = {
            "principal": {"id": GROUP_ID, "type": "Group"},
            "role": ROLE,
        }
        acl_url = f"{WORKSPACES_URL}/{workspace_id}/roleAssignments"
        acl_response = requests.post(acl_url, headers=headers, json=acl_body)
        acl_response.raise_for_status()
        print(f"  - Assigned group {GROUP_ID} as {ROLE}")
