# 🧪 Lab 4 - Data Integration

## 🎯 Goal

Deploy and run the workshop integration framework in Microsoft Fabric by loading metadata into the configuration database, ingesting Rebrickable source data into Landing, and executing the full Landing to Bronze to Silver orchestration pipeline.

## Overview

In this lab, you connect the platform foundation from Part 1 and Part 2 to an operational integration flow.

You will:
- Deploy the integration assets (notebooks, pipelines, variable library, SQL database artifacts)
- Load framework metadata into your Fabric configuration database
- Ingest Rebrickable source tables into `LH_Data_Landingzone`
- Configure `VAR_CONFIG_FMD` with your workspace, lakehouse, and database identifiers
- Run `PL_FMD_LOAD_ALL` to execute the full data integration sequence

## Prerequisites

Before you start:
- Complete Part 1 and Part 2 successfully
- Create a Fabric Database connection, connection id is used in later stage
- Confirm your code, data, and config workspaces exist
- Confirm `LH_Data_Landingzone`, `LH_Bronze_Layer`, and `LH_Silver_Layer` exist in the data workspace
- Confirm your configuration Fabric Database exists
- Open these files in this lab folder:
	- `NB_SETUP_WORKSHOP_FINAL.ipynb`
	- `NB_INGEST_REBRICKABLE.ipynb`
	- `insert_metadata_labs.sql`

## Assets Deployed in This Lab

The setup notebook deploys these integration items:
- Notebooks:
	- `NB_FMD_PROCESSING_PARALLEL_MAIN`
	- `NB_FMD_LOAD_LANDING_BRONZE`
	- `NB_FMD_LOAD_BRONZE_SILVER`
- Pipelines:
	- `PL_FMD_LDZ_COPY_FROM_ONELAKE_TABLES_01`
	- `PL_FMD_LOAD_LANDINGZONE`
	- `PL_FMD_LOAD_BRONZE`
	- `PL_FMD_LOAD_SILVER`
	- `PL_FMD_LOAD_ALL`
- Variable library:
	- `VAR_CONFIG_FMD`
- SQL Database project artifact:
	- `SQL_XXXXX` (Fabric Database with stored procedures and tables for metadata-driven orchestration)

## Lab Tasks

### Task 1: Run Setup Deployment Notebook

1. Open `NB_SETUP_WORKSHOP_FINAL.ipynb`.
2. Review and update the parameter cell values for:
	 - `workspace_name_code`
	 - `workspace_name_data`
	 - `workspace_name_config`
	 - `database_name`
3. Keep repo configuration defaults unless your instructor specifies a different branch or folder source.
4. Run the notebook top to bottom.
5. Confirm all notebooks, pipelines, variable library, and SQL database artifact are created in the expected workspaces.

Expected result:
- Deployment completes without import errors.

### Task 2: Load Metadata into the Configuration Database

1. Open `insert_metadata_labs.sql`.
2. In the script, update `@DataSourceId` only if your environment requires a different source mapping.
3. Open your configuration Fabric Database query editor.
4. Execute the full script.
5. Confirm the script finishes without `RAISERROR`.

Expected result:
- Metadata rows are upserted through `[integration].[sp_UpsertLandingzoneBronzeSilver]` for all Rebrickable source tables.

### Task 3: Ingest Rebrickable Data into Landing

1. Open `NB_INGEST_REBRICKABLE.ipynb` in the code workspace.
2. In the parameters cell, set:
	 - `landing_lakehouse_name` to `LH_Data_Landingzone`
	 - `landing_workspace_id` to your data workspace GUID
3. Run the notebook end-to-end.
4. Confirm Delta tables are created for all Rebrickable datasets in the Data Landing lakehouse.

Expected result:
- Landing contains tables such as `colors`, `themes`, `parts`, `sets`, `inventory_parts`, and related entities.

### Task 4: Configure Variable Library Values

1. Open variable library `VAR_CONFIG_FMD` in the code workspace.
2. Update variables to match your environment IDs and connection values.
3. Verify at minimum these variables are correct:
	 - `fmd_config_workspace_guid`
	 - `fmd_config_database_guid`
	 - `fmd_fabric_db_connection`
     - `fmd_fabric_db_name`
     - `fmd_fabric_db_connectionstring`
	 - `data_workspace`
	 - `LH_Data_Landingzone`
	 - `LH_Bronze_Layer`
	 - `LH_Silver_Layer`

4. Save and publish the library changes.

Expected result:
- Pipelines and notebooks can resolve all referenced workspace, lakehouse, and database resources.

### Task 5: Run the End-to-End Pipeline

1. Open pipeline `PL_FMD_LOAD_ALL`.
2. Trigger a pipeline run.
3. Monitor execution and confirm these stages complete in sequence:
	 - `PL_FMD_LOAD_LANDINGZONE`
	 - `PL_FMD_LOAD_BRONZE`
	 - `PL_FMD_LOAD_SILVER`
4. Investigate and rerun failed stages if needed after fixing configuration issues.

Expected result:
- End-to-end orchestration succeeds from Landing to Bronze to Silver.

## Validation Checklist

Before finishing this lab, verify:
- Integration assets are deployed to the correct workspaces
- `insert_metadata_labs.sql` completed successfully
- Rebrickable tables exist in `LH_Data_Landingzone`
- `VAR_CONFIG_FMD` values match your environment
- `PL_FMD_LOAD_ALL` completed successfully
- Bronze and Silver layers contain transformed outputs

## Troubleshooting

If execution fails:
- Recheck workspace, lakehouse, and database GUIDs in `VAR_CONFIG_FMD`
- Confirm the Fabric DB connection variable points to a valid SQL endpoint connection
- Confirm `landing_workspace_id` in `NB_INGEST_REBRICKABLE.ipynb` is your data workspace ID
- Re-run `insert_metadata_labs.sql` and check for stored procedure errors
- Open failed pipeline activity output to identify missing IDs, missing objects, or SQL execution failures

## Expected Outcome

At the end of this lab, you have:
- A deployed metadata-driven integration framework in Fabric
- Rebrickable source data loaded into Landing
- Metadata rules stored in the configuration database
- A successful orchestrated load through Landing, Bronze, and Silver