🧪 Exercise - Data Preparation (Gold Layer)

## Objective

Set up the Gold layer environment in Microsoft Fabric by creating the required workspaces and Gold lakehouse, creating OneLake shortcuts to curated tables, generating a DimDate table, and building Materialized Lake Views for analytics consumption.

## Overview

This lab builds on the Landing, Bronze, and Silver integration completed in earlier labs.

You will:
- Deploy Gold layer base assets with the setup notebook
- Create shortcuts in the Gold lakehouse to source tables
- Generate a reusable Gold date dimension table
- Create or refresh Materialized Lake Views in schema `gold`

## Prerequisites

Before starting:
- Complete previous labs successfully
- Confirm your source curated tables are available in the upstream workspace/lakehouse
- Confirm you can run these notebooks:
  - NB_SETUP_WORKSHOP_GOLD.ipynb
  - NB_CREATE_SHORTCUTS.ipynb
  - NB_CREATE_DIMDATE.ipynb
  - NB_MLV_DEMO_GOLD .ipynb

## Lab Tasks

### Task 1: Deploy Gold Base Assets

1. Open NB_SETUP_WORKSHOP_GOLD.ipynb.
2. Review and update workspace parameters:
	- `workspace_name_code`
	- `workspace_name_data`
	- `workspace_name_semantic`
3. Keep `lakehouses=['LH_Gold_Layer']` unchanged.
4. Run the notebook top to bottom.
5. Confirm the following are created:
	- Code workspace
	- Data workspace
	- Semantic workspace
	- Lakehouse `LH_Gold_Layer` in the data workspace


Expected result:
- Gold workspaces and `LH_Gold_Layer` are provisioned and ready.

### Task 2: Create Gold Shortcuts to Source Tables

1. Open NB_CREATE_SHORTCUTS.ipynb.
2. Update the parameter cell values:
	- `ShortcutNames`
	- `SourceWorkspaceId`
	- `SourceLakehouseId`
	- `SourceSchema`
	- `Shortcut_TargetSchema`
	- `Shortcut_TargetWorkspaceId`
	- `Shortcut_TargetLakehouseId`
3. Keep the full table list in `ShortcutNames` unless your instructor specifies a subset.
4. Run all cells.
5. Confirm shortcuts are created successfully under the destination schema.

Parameter meaning:
- `SourceWorkspaceId` and `SourceLakehouseId`: destination lakehouse where shortcuts are created (Gold).
- `Shortcut_TargetWorkspaceId` and `Shortcut_TargetLakehouseId`: source lakehouse referenced by the shortcut target.

Expected result:
- Gold lakehouse exposes shortcut-backed tables for the selected Rebrickable entities.


Expected result:
- A reusable Gold date dimension table is available for semantic models and reporting.

### Task 3: Create Materialized Lake Views

1. Open NB_MLV_DEMO_GOLD .ipynb.
2. Ensure the notebook is attached to the correct default lakehouse in your data workspace.
3. Run all SQL cells to create or replace Materialized Lake Views in schema `gold`.
4. Refresh your lakehouse view graph and confirm views are visible.

Views created include:
- `gold.Colors`
- `gold.elements`
- `gold.inventories`
- `gold.inventory_minifigs`
- `gold.inventory_parts`
- `gold.inventory_sets`
- `gold.minifigs`
- `gold.part_categories`
- `gold.part_relationships`
- `gold.parts`
- `gold.sets`
- `gold.themes`

Expected result:
- Gold materialized views are created and refreshed for analytics-ready consumption.

## Validation Checklist

Before completing this lab, verify:
- Gold workspaces and `LH_Gold_Layer` are deployed
- Shortcuts exist for all required source tables
- Materialized lake views in schema `gold` are present
- Querying Gold views returns expected data

## Troubleshooting

If something fails:
- Recheck workspace and lakehouse GUID values in the shortcuts notebook
- Confirm destination/source shortcut parameters are not swapped
- Confirm default lakehouse attachment before running Gold SQL notebook
- Re-run failed notebook cells after correcting configuration values
- If a shortcut already exists, use overwrite mode or remove/recreate the shortcut

## Expected Outcome

At the end of this lab, you have:
- A provisioned Gold layer workspace setup
- Shortcut-based access to curated tables in the Gold lakehouse
- A set of Gold Materialized Lake Views for downstream BI and semantic modeling

