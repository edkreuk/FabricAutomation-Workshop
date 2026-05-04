# 🧪 Lab 1 – Tooling Landscape

## 🎯 Goal

Get hands-on with the tools we just walked through: REST APIs (public and unsupported), the Fabric CLI, the Fabric SDKs, and the Fabric MCP servers. By the end of this lab you should have called Fabric in at least three different ways - and have a feel for which tool fits which job.

> 💡 The exercises are progressive. Pick a workspace name prefix you'll recognize (e.g. your initials) so cleanup at the end is easy.

---

## 📋 How to use this lab

Each exercise has two collapsible blocks:

- **📖 Task & details**: What to do, with hints and links
- **💡 Solution**: A working answer you can peek at if you get stuck (or copy and adapt)

You're encouraged to *try first, peek second*. The fastest learning happens when you struggle for five minutes before opening the solution.

The demo code lives in [Demos/02 Tooling Landscape/](../../Demos/02%20Tooling%20Landscape/). Feel free to use it as a starting point.

---

## Exercise 1 — Find your Fabric foundations

<details>
<summary>📖 <strong>Task & details</strong></summary>

Almost every automation call to Fabric needs a few core IDs. Before you write any code, find these for your environment and write them down somewhere you can paste from:

1. Your **tenant ID** (the Entra/AAD tenant)
2. The **ID of one Fabric capacity** you can deploy workspaces to
3. The **ID of one workspace** you have access to

**Question:** How many different ways can you find these without asking an admin?

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

There's no single right answer. Finding the same value multiple ways *is* the point. Some options:

- **Portal**: tenant ID under Microsoft Entra → Overview. Capacity ID via Settings → Admin portal → Capacity settings (URL contains the ID). Workspace ID is in the URL when you open it (`/groups/<workspace-id>/...`).
- **Fabric CLI**: `fab auth status` shows the tenant. `fab ls /.capacities` lists capacities. `fab get "My Workspace.Workspace" -q id` returns a workspace ID.
- **REST API**: `GET https://api.fabric.microsoft.com/v1/capacities` and `GET https://api.fabric.microsoft.com/v1/workspaces`.
- **Azure CLI**: `az account show` returns the current tenant ID.

Save these somewhere, you'll reuse them all later.

</details>

---

## Exercise 2 — Hello, Fabric CLI

<details>
<summary>📖 <strong>Task & details</strong></summary>

Install the Fabric CLI, sign in, and list every workspace you can see.

- Install with `pip install ms-fabric-cli` (Python 3.10+).
- See [Demos/02 Tooling Landscape/Fabric CLI/workspace-commands.txt](../../Demos/02%20Tooling%20Landscape/Fabric%20CLI/workspace-commands.txt) for a cheat-sheet.

**Concrete output:** the list of your workspaces printed to the terminal.

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

```bash
pip install ms-fabric-cli
fab auth login
fab ls
```

`fab ls` (with no arguments) lists everything at the root — all workspaces visible to your identity.

</details>

---

## Exercise 3 — Minimum-commands challenge

<details>
<summary>📖 <strong>Task & details</strong></summary>

Using **only the Fabric CLI**, what is the minimum number of commands you need to run to:

1. Create a workspace called `<your-initials>-Lab1` on a Fabric capacity, **and**
2. Create a Lakehouse called `Bronze` inside it?

Assume you're already authenticated. Count each command (each line you run) as one.

**Concrete task:** Actually run them, then write down the count and paste the commands into your notes.

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

**Two commands** — both use `mkdir`:

```bash
fab mkdir "<your-initials>-Lab1.Workspace" -P capacityName=<your-capacity-name>
fab mkdir "<your-initials>-Lab1.Workspace/Bronze.Lakehouse"
```

(If you weren't authenticated, add `fab auth login` for a third.)

That's the magic of the file-system metaphor — `mkdir` works for both workspaces and items.

</details>

---

## Exercise 4 — Read the contract: REST API in the browser

<details>
<summary>📖 <strong>Task & details</strong></summary>

Open the [Create Workspace REST API docs page](https://learn.microsoft.com/en-us/rest/api/fabric/core/workspaces/create-workspace) in your browser and use the **"Try it"** button (top right) to call it directly. No code, no Postman.

Answer these:

1. Which fields in the request body are **required** vs. optional?
2. Can you create a workspace **without** a capacity? If yes, what state is it in afterwards?
3. What HTTP status code do you get back on success, and what does the response body contain?

**Concrete task:** create a workspace called `<your-initials>-Lab1-tryit` from the docs page and verify it appears in [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

1. Only `displayName` is required. `description` and `capacityId` are optional.
2. Yes. A workspace with no capacity is created in "Pro" mode (no Fabric items, only Power BI). You can assign a capacity later via the [Assign To Capacity](https://learn.microsoft.com/en-us/rest/api/fabric/core/workspaces/assign-to-capacity) endpoint or in the portal.
3. `201 Created`, with the full workspace object, including the new `id`, which you'll need for any follow-up calls.

The "Try it" button is severely underrated for exploring an API before you commit to writing code.

</details>

---

## Exercise 5 — Acquire a token and call Fabric yourself

<details>
<summary>📖 <strong>Task & details</strong></summary>

Pick **one** of: Postman, PowerShell, or Python. From your local machine:

1. Acquire a bearer token for the Fabric API (audience `https://api.fabric.microsoft.com/.default`).
2. Call `GET https://api.fabric.microsoft.com/v1/workspaces`.
3. Print the **count** of workspaces and the **name + ID** of each.

**Hint:** PowerShell users: `Connect-AzAccount` followed by `Get-AzAccessToken -ResourceUrl ...` is the shortest path. Python users: `azure.identity.InteractiveBrowserCredential` does the OAuth for you. Postman users: set up an OAuth 2.0 auth on the request itself.

Reference: [Demos/02 Tooling Landscape/Fabric REST API/list-workspaces.py](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API/list-workspaces.py) and [list-workspaces.ps1](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API/list-workspaces.ps1).

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

**Python** (interactive auth):

```python
import requests
from azure.identity import InteractiveBrowserCredential

token = InteractiveBrowserCredential().get_token("https://api.fabric.microsoft.com/.default").token
r = requests.get(
    "https://api.fabric.microsoft.com/v1/workspaces",
    headers={"Authorization": f"Bearer {token}"},
)
r.raise_for_status()
workspaces = r.json()["value"]
print(f"Found {len(workspaces)} workspaces")
for ws in workspaces:
    print(f"  {ws['displayName']:40} {ws['id']}")
```

**PowerShell**:

```powershell
Connect-AzAccount | Out-Null
$token = (Get-AzAccessToken -ResourceUrl "https://api.fabric.microsoft.com").Token
$ws = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces" `
    -Headers @{ Authorization = "Bearer $token" }
"Found $($ws.value.Count) workspaces"
$ws.value | ForEach-Object { "{0,-40} {1}" -f $_.displayName, $_.id }
```

**Postman**: import [Fabric-API.postman_collection.json](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API/Fabric-API.postman_collection.json) and configure OAuth 2.0 in the collection's Authorization tab — auth URL `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize`, token URL `.../token`, scope `https://api.fabric.microsoft.com/.default`.

</details>

---

## Exercise 6 — Programmatic workspace creation

<details>
<summary>📖 <strong>Task & details</strong></summary>

Now write code that creates a workspace **and** assigns it to your Fabric capacity. Use any language and tool you're comfortable with, just don't use the portal or the CLI for this one.

**Requirements:**

- Workspace name `<your-initials>-Lab1-api`
- A non-empty `description`
- Assigned to your Fabric capacity (so you can put Fabric items inside it)

**Bonus:** also assign a security group to the workspace as a member (skip if you don't have a group ID handy).

Reference: [Demos/02 Tooling Landscape/Fabric REST API/create-workspaces.py](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API/create-workspaces.py) and [create-workspaces.ps1](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API/create-workspaces.ps1).

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

Single-shot Python version (interactive auth):

```python
import requests
from azure.identity import InteractiveBrowserCredential

CAPACITY_ID = "<your-capacity-id>"
INITIALS    = "<your-initials>"

token = InteractiveBrowserCredential().get_token(
    "https://api.fabric.microsoft.com/.default"
).token
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

r = requests.post(
    "https://api.fabric.microsoft.com/v1/workspaces",
    headers=headers,
    json={
        "displayName": f"{INITIALS}-Lab1-api",
        "description": "Created from Lab 1 via REST API.",
        "capacityId":  CAPACITY_ID,
    },
)
r.raise_for_status()
print("Created:", r.json()["id"])
```

The full demo script also wires in optional security-group ACL assignment.

</details>

---

## Exercise 7 — Try one of the SDKs

<details>
<summary>📖 <strong>Task & details</strong></summary>

Pick **one** SDK that matches your stack:

| SDK | Package |
|-----|---------|
| Python | `microsoft-fabric-api` |
| .NET | `Microsoft.Fabric.Api` (NuGet) |
| Go | `github.com/microsoft/fabric-sdk-go` |

Build a small program (script, console app or web app - your call) that:

1. Lists all workspaces you have access to.
2. For each workspace, prints how many **items** it contains.

The point is to feel the difference between calling the raw HTTP endpoints (Exercise 5) and using a typed SDK.

References: [Demos/02 Tooling Landscape/Fabric Python SDK/list-workspaces.py](../../Demos/02%20Tooling%20Landscape/Fabric%20Python%20SDK/list-workspaces.py) and the .NET project at [Demos/02 Tooling Landscape/Fabric .Net SDK/FabricSpeedyCreator/](../../Demos/02%20Tooling%20Landscape/Fabric%20.Net%20SDK/FabricSpeedyCreator/).

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

**Python**:

```python
from azure.identity import InteractiveBrowserCredential
from microsoft_fabric_api import FabricClient

client = FabricClient(InteractiveBrowserCredential())

for ws in client.core.workspaces.list_workspaces():
    items = list(client.core.items.list_items(workspace_id=ws.id))
    print(f"{ws.display_name:40} ({len(items)} items)")
```

**.NET (top-level statements)**:

```csharp
using Azure.Identity;
using Microsoft.Fabric.Api;

var client = new FabricClient(new InteractiveBrowserCredential());

await foreach (var ws in client.Core.Workspaces.ListWorkspacesAsync())
{
    var count = 0;
    await foreach (var _ in client.Core.Items.ListItemsAsync(ws.Id)) count++;
    Console.WriteLine($"{ws.DisplayName,-40} ({count} items)");
}
```

The SDK does the auth, paging, retries, and JSON serialization for you. Compare that with the raw HTTP version from Exercise 5.

</details>

---

## Exercise 8 — Reach into the unsupported APIs

<details>
<summary>📖 <strong>Task & details</strong></summary>

Public APIs don't cover everything. The internal `wabi-*-redirect.analysis.windows.net/metadata/...` endpoints power the Fabric portal itself, and they expose things you can't (yet) do via the public API, like setting a custom workspace icon.

Open [Demos/02 Tooling Landscape/Fabric REST API (INTERNAL)/Maintain Workspace Icons.ipynb](../../Demos/02%20Tooling%20Landscape/Fabric%20REST%20API%20(INTERNAL)/Maintain%20Workspace%20Icons.ipynb) in a Fabric notebook (it uses `notebookutils` to grab a token).

1. Run it in **dry-run mode** against one of your workspaces (set `must_contain` to part of the workspace name, leave `is_dryrun = True`).
2. Look at how it discovers the cluster URL. What does it do that public endpoints don't require?
3. **Bonus:** flip `is_dryrun = False` and apply an icon to a workspace you own.

**Question to answer:** what are the trade-offs of using internal endpoints in a real solution?

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

The notebook discovers the **regional cluster URL** (e.g. `wabi-west-europe-b-primary-redirect.analysis.windows.net`) by inspecting the `@odata.context` field on a Power BI API response, then targets that host directly. Public Fabric APIs always go through `api.fabric.microsoft.com`, internal ones are tenant/region-specific.

**Trade-offs of internal endpoints:**

- ✅ Unlocks features the public API doesn't expose yet.
- ❌ No SLA, no contract — Microsoft can change them at any time.
- ❌ Generally only work for **user** principals (no SPN support guaranteed).
- ❌ Often require extra headers (e.g. `X-PowerBI-User-Admin: true` for admin endpoints) and undocumented query params.
- ❌ Documentation is reverse-engineered — you'll be reading browser DevTools.

Use them for tooling and one-offs; avoid them in production-critical paths.

</details>

---

## Exercise 9 — Talk to Fabric in natural language (stretch)

<details>
<summary>📖 <strong>Task & details</strong></summary>

Configure a Fabric MCP server in the AI client of your choice (Claude Desktop, Cursor, GitHub Copilot in VS Code, …) and ask it about your tenant.

- Local MCP (GA): runs on your machine, has Fabric API knowledge + OneLake browsing. See [Demos/02 Tooling Landscape/Fabric MCP/README.md](../../Demos/02%20Tooling%20Landscape/Fabric%20MCP/README.md) for links.
- Remote MCP (Preview): Microsoft-hosted, executes against your real workspaces with your Entra identity.

**Concrete tasks:**

1. Get the MCP wired up in your client.
2. Ask it: *"List my Fabric workspaces and tell me which capacity each one is on."*
3. Ask it: *"Create a workspace called `<your-initials>-Lab1-mcp` on capacity `<name>`."*. Observe what it does and which tools/APIs it picks.

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

Setup details vary per client, but the shape is the same:

1. Follow the [local pro-dev MCP guide](https://learn.microsoft.com/en-us/rest/api/fabric/articles/mcp-servers/pro-dev-local/get-started-local) or the [remote core MCP guide](https://learn.microsoft.com/en-us/rest/api/fabric/articles/mcp-servers/core-remote/get-started-core) to register the server.
2. In your client's MCP settings, add the server entry it gives you. Restart the client.
3. The agent will surface a set of Fabric *tools* (workspaces, items, OneLake, …). It picks them based on your prompt.

You'll notice it composes calls: list workspaces → list capacities → match by name → call create. That's the same Fabric REST API you used in Exercise 5, just driven by a model instead of you.

</details>

---

## Exercise 10 — Bake-off: ClickOps vs CLI vs API

<details>
<summary>📖 <strong>Task & details</strong></summary>

Time to feel the *why* of automation in your fingers.

For the same task, do it **three ways** and write down what each cost you:

> **Task:** Create a workspace `<your-initials>-Lab1-bakeoff`, assign it to your capacity, and create three lakehouses inside it called `Bronze`, `Silver`, `Gold`. Each with a description.

| Approach | Time taken | Clicks / keystrokes / lines of code |
|----------|-----------|-----|
| Portal (ClickOps) | | |
| Fabric CLI | | |
| REST API or SDK | | |

**Reflection questions:**

1. Which approach was fastest *the first time*? Which would be fastest the *tenth* time?
2. Which approach scales best to **50 workspaces** following the same pattern?
3. Which approach is easiest to put into a Git repo and review in a PR?

</details>

<details>
<summary>💡 <strong>Solution</strong></summary>

There's no "correct" timing, yours will depend on tooling familiarity. But the general shape almost always lands like this:

| Approach | First-time cost | Repeat cost | Reviewable in Git? |
|----------|----------------|-------------|---------------------|
| Portal | Lowest — 5–10 min | Linear: 5–10 min × N | No |
| Fabric CLI | Low — a few minutes once you know `mkdir` | Near-zero with a script | Yes |
| REST API / SDK | Highest setup (auth, deps) | Near-zero, fully programmable | Yes |

The whole reason we covered this tooling stack is that **the upfront cost of a CLI/SDK pays back the first time you need to do this task more than once or hand it to a teammate**. ClickOps wins exactly once, and never again.

</details>

---

## 🧹 Cleanup

If you used your initials prefix consistently, you can wipe everything from the lab in one shot:

```bash
fab rm "<your-initials>-Lab1.Workspace" --force
fab rm "<your-initials>-Lab1-tryit.Workspace" --force
fab rm "<your-initials>-Lab1-api.Workspace" --force
fab rm "<your-initials>-Lab1-mcp.Workspace" --force
fab rm "<your-initials>-Lab1-bakeoff.Workspace" --force
```

…or interactively from the root: `fab rm .` (then pick).

---

## ✅ Outcome

You've now called the Fabric platform from the portal, the CLI, the REST API directly, an SDK, an internal endpoint, and an AI agent. You've felt the trade-off curve between "easy to start" and "scales well", which is exactly the lens we'll use for the rest of the workshop.
