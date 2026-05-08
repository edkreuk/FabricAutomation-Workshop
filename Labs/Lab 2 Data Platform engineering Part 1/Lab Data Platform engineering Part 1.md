# 🧪 Lab 2 - Data Platform Engineering Part 1

## 🎯 Goal

Build the initial Microsoft Fabric platform foundation for the workshop by creating separate code and data workspaces, enabling managed identities, and provisioning the first Medallion Architecture lakehouses.

## Overview

In this exercise, you will create the core Fabric structure used throughout the rest of the workshop. The setup is intentionally split into two workspaces so that orchestration assets and storage assets remain separated.

You will use the setup notebook to:
- Configure the Fabric capacity for the workshop assets
- Authenticate the Fabric CLI inside the notebook session
- Create a code workspace and a data workspace
- Add a workspace identity to each workspace
- Add descriptions for governance and maintainability
- Create three lakehouses that represent the Medallion layers
- Create an empty starter notebook in the code workspace

## Prerequisites

Before you begin, make sure:
- You have access to a Microsoft Fabric enabled tenant
- You have permission to create and manage Fabric workspaces and items
- You have access to a Fabric capacity that can host the workshop artifacts
- You can open and run `NB_SETUP_WORKSHOP_ENGINEERING_PART_1.ipynb`

## Naming Conventions

Use the naming standard from the notebook throughout the lab:
- `PL` = Pipeline
- `NB` = Notebook
- `VAR` = Variable Library
- `SQL` = Fabric Database
- `LH` = Lakehouse
- `WH` = Warehouse
- `WS` = Workspace

Use names that clearly identify you or your team, while preserving the workshop prefixes.

## Architecture for This Lab

You will create two workspaces:
- A code workspace for notebooks, orchestration logic, and later automation assets
- A data workspace for the medallion storage layers

Inside the data workspace, you will create three lakehouses:
- `LH_Data_Landingzone`
- `LH_Bronze_Layer`
- `LH_Silver_Layer`

These represent the first three layers of the Medallion Architecture:
- Landing Zone for raw incoming files
- Bronze for ingested source-aligned data
- Silver for cleaned and standardized data

## Lab Tasks

### Task 1: Open the Setup Notebook

1. Open `NB_SETUP_WORKSHOP_ENGINEERING_PART_1.ipynb`.
2. Review the notebook sections before running any code.


### Task 2: Verify Fabric CLI Availability

The notebook includes an install cell for the Fabric CLI. In many workshop environments with Python 3.12, the CLI is already available.

1. Review the install command in the notebook.
2. If Fabric CLI is not available, uncomment and run the install command.
3. If it is already available, continue without changing the cell.

Expected result:
- The notebook environment can execute `fab` commands.

### Task 3: Review the Capacity Configuration

1. Locate the `capacity_name` variable.
2. Review the default capacity value provided in the notebook.
3. Confirm that the workspace creation commands use that value consistently.

Expected result:
- All newly created workshop items will be assigned to the intended Fabric capacity.


### Task 4: Create the Code and Data Workspaces

1. Review the predefined values for:
	- `workspace_name_code`
	- `workspace_name_data`
2. Run the workspace creation commands.
3. Confirm both workspaces are created successfully and assigned to the configured capacity.

Expected result:
- One dedicated code workspace exists.
- One dedicated data workspace exists.

### Task 5: Create a Workspace Identity for Each Workspace

1. Run the cell that creates the managed identity for the code workspace.
2. Run the cell that creates the managed identity for the data workspace.
3. Verify both identities are created successfully.

Why this matters:
- Managed identities allow workspaces to access resources securely without embedding personal credentials in notebooks or pipelines.

Expected result:
- Both workspaces have a managed identity assigned.

### Task 6: Add Descriptions to the Workspaces

1. Review the payload used by the notebook.
2. Confirm the description explains that the workspace content is generated through the Fabric CLI and may be overwritten when the setup notebook is rerun.
3. Run the commands that apply the descriptions to both workspaces.

Expected result:
- Both workspaces have clear, governance-friendly descriptions.

### Task 7: Create the Medallion Lakehouses

1. Review the `lakehouses` list in the notebook.
2. Keep the provided names unchanged:
	- `LH_Data_Landingzone`
	- `LH_Bronze_Layer`
	- `LH_Silver_Layer`
3. Run the loop that creates the lakehouses in the data workspace.
4. Confirm that schema support is enabled during creation.

Expected result:
- All three lakehouses are created in the data workspace.

### Task 8: Add Descriptions to the Lakehouses

1. Run the description commands for each lakehouse.
2. Verify the descriptions clearly state the role of each layer:
	- Landing Zone
	- Bronze
	- Silver
3. Confirm the descriptions are visible in Fabric.

Expected result:
- Each lakehouse is documented with its functional purpose.

### Task 9: Create an Empty Notebook in the Code Workspace

1. Review the `notebook_name` variable.
2. Run the notebook creation cell in the code workspace.
3. Confirm that the notebook has been created in the code workspace.

Expected result:
- A starter notebook exists in the code workspace and is ready for later exercises.

## Validation Checklist

Before moving on, confirm all of the following:
- The code workspace has been created
- The data workspace has been created
- Both workspaces are assigned to the intended capacity
- Both workspaces have managed identities
- Both workspaces have descriptions
- The three medallion lakehouses exist in the data workspace
- Each lakehouse has a clear description
- The starter notebook exists in the code workspace
- The starter notebook has a description

## Expected Outcome

At the end of this exercise, you should have:
- A structured two-workspace Fabric foundation
- Managed identities configured for both workspaces
- A three-layer Medallion Architecture implemented in the data workspace
- A starter notebook prepared in the code workspace for later development

## Troubleshooting

If you run into issues:
- Verify that the configured capacity is correct and available to your account
- Confirm the Fabric CLI token is being set correctly in the notebook session
- Check whether the predefined workspace names already exist in the tenant if creation fails
- Ensure the lakehouse names are not changed, as later exercises depend on them
- If an item already exists, decide whether to reuse it or delete and recreate it before rerunning the failed step

## Next Step

After completing this lab, continue to Part 2 where you will add a dedicated configuration workspace and Fabric Database to support metadata-driven automation.


