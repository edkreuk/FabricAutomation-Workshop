"""
List Microsoft Fabric workspaces using the Fabric REST API.

Supports two authentication modes:
  - INTERACTIVE: Browser-based sign-in (user identity)
  - SPN: Service Principal (client ID + secret)

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

FABRIC_SCOPE    = "https://api.fabric.microsoft.com/.default"
WORKSPACES_URL  = "https://api.fabric.microsoft.com/v1/workspaces"

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

# ----------------------------------------------------------------------------
# LIST WORKSPACES
# ----------------------------------------------------------------------------
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json",
}

response = requests.get(WORKSPACES_URL, headers=headers)
response.raise_for_status()

workspaces = response.json().get("value", [])
print(f"Found {len(workspaces)} workspaces\n")

for ws in workspaces:
    capacity_id = ws.get("capacityId", "N/A")
    print(f"* {ws.get('displayName')} (ID: {ws.get('id')}, Capacity ID: {capacity_id})")