# =============================================================================
# Fabric REST APIs - Automated Setup of medalion architecture
# Docs: https://learn.microsoft.com/en-us/rest/api/fabric
# =============================================================================

## Configuration - Update these variables with your own values before running the script ######
capacityId = "<your-capacity-id>"
workspaceName = "Fabric REST API"
groupId = "<your-group-id>" # Optional - only needed if you want to assign roles to users/groups in your tenant (e.g. workspace admin/member)

import requests, time, jwt, base64
from requests.adapters import HTTPAdapter, Retry
from azure.identity import InteractiveBrowserCredential
from azure.core.credentials import AccessToken, TokenCredential
from datetime import datetime

import warnings
warnings.filterwarnings(
    "ignore",
    message=".*response_mode='form_post'.*",
    category=UserWarning,
)

credential = InteractiveBrowserCredential()

_token = credential.get_token("https://api.fabric.microsoft.com/.default").token
decoded_token = jwt.decode(_token, options={"verify_signature": False})

print(f'Signed in as {decoded_token.get("name")} ({decoded_token.get("upn")})')
def invoke_fabric_api_request(method, uri, payload=None, api_endpoint="api.fabric.microsoft.com/v1"):
    headers = {
        "Authorization": "Bearer " + _token,
        "Content-Type": "application/json"
    }

    try:
        url = f"https://{api_endpoint}/{uri}"
            
        session = requests.Session()
        retries = Retry(total=3, backoff_factor=5, status_forcelist=[502, 503, 504])
        adapter = HTTPAdapter(max_retries=retries)
        session.mount('http://', adapter)
        session.mount('https://', adapter)

        response = session.request(method, url, headers=headers, json=payload, timeout=240)      
        if (response.status_code == 202):
            operation_id = response.headers.get('x-ms-operation-id')
            
            # Poll the operation status until it's done - sleep 2 seconds between polls
            while True:
                operation_state_response = invoke_fabric_api_request("get", f"operations/{operation_id}")
                operation_state = operation_state_response.json().get("status")

                if operation_state in ["NotStarted", "Running"]:
                    time.sleep(2)
                elif operation_state == "Succeeded":
                    response = invoke_fabric_api_request("get", f"operations/{operation_id}/result")
                    break
                else:
                    break
        
        return response

    except requests.RequestException as ex:
        print(ex)


start_time = datetime.now()

### Create workspace
workspace = invoke_fabric_api_request(
    method="post",
    uri="workspaces",
    payload={
        "displayName": workspaceName,
        "description": "This workspace was created using the Fabric REST API",
        "capacityId": capacityId
    }
)
print("Workspace created with ID: " + workspace.json().get("id"))

### Add Workspace Member Role
if groupId is not None:
    role_assignment = invoke_fabric_api_request(
        method="post",
        uri=f"workspaces/{workspace.json().get('id')}/roleAssignments",
        payload={
            "principal": {
                "id": groupId,
                "type": "Group"
            },
            "role": "Member"
        }
    )

### Create lakehouses (landing, base, curated)
lakehouse = invoke_fabric_api_request(
    method="post",
    uri=f"workspaces/{workspace.json().get('id')}/lakehouses",
    payload={
        "displayName": "Landing",
        "description": "Landing lakehouse for raw data"
    }
)
print("Landing lakehouse created with ID: " + lakehouse.json().get("id"))

### Create base lakehouse
lakehouse = invoke_fabric_api_request(
    method="post",
    uri=f"workspaces/{workspace.json().get('id')}/lakehouses",
    payload={
        "displayName": "Base",
        "description": "Base lakehouse for processed data"
    }
)
print("Base lakehouse created with ID: " + lakehouse.json().get("id"))

### Create curated lakehouse
lakehouse = invoke_fabric_api_request(
    method="post",
    uri=f"workspaces/{workspace.json().get('id')}/lakehouses",
    payload={
        "displayName": "Curated",
        "description": "Curated lakehouse for analytics"
    }
)
print("Curated lakehouse created with ID: " + lakehouse.json().get("id"))

### Read notebook file and encode as base64
with open("Demos/Resources/Rebrickable - Ingest.Notebook/Rebrickable - Ingest.ipynb", "rb") as f:
    notebook_payload = base64.b64encode(f.read()).decode()

### Import notebook into workspace
notebook = invoke_fabric_api_request(
    method="post",
    uri=f"workspaces/{workspace.json().get('id')}/notebooks",
    payload={
        "displayName": "Rebrickable - Ingest",
        "description": "Ingestion notebook for Rebrickable data, imported using the REST API",
        "definition": {
            "format": "ipynb",
            "parts": [
                {
                    "path": "notebook-content.ipynb",
                    "payload": notebook_payload,
                    "payloadType": "InlineBase64"
                }
            ]
        }
    }
)
print("Rebrickable - Ingest notebook created with ID: " + notebook.json().get("id"))

duration = datetime.now() - start_time
print(f"Script duration: {duration}")