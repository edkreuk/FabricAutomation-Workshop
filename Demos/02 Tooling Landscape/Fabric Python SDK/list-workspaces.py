"""
List Microsoft Fabric workspaces using the Microsoft Fabric Python SDK.

Uses interactive browser authentication (user identity).

Prerequisites:
  pip install microsoft-fabric-api azure-identity
"""

from azure.identity import InteractiveBrowserCredential
from microsoft_fabric_api import FabricClient

# ----------------------------------------------------------------------------
# AUTHENTICATION
# ----------------------------------------------------------------------------
credential = InteractiveBrowserCredential()
fabric_client = FabricClient(credential)

# ----------------------------------------------------------------------------
# LIST WORKSPACES
# ----------------------------------------------------------------------------
workspaces = list(fabric_client.core.workspaces.list_workspaces())
print(f"Found {len(workspaces)} workspaces\n")

for ws in workspaces:
    capacity_id = ws.capacity_id or "N/A"
    print(f"* {ws.display_name} (ID: {ws.id}, Capacity ID: {capacity_id})")
