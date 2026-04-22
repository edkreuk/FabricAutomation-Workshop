🧪 Exercise - Data Platform Engineering Part 1

## Objective

Build a well-organized Fabric workspace with a Medallion Architecture using parameterized configuration for scalability and governance.

## Overview

In this exercise, you'll establish a solid foundation for enterprise data engineering by creating two specialized workspaces:
- A **code workspace** for notebooks, pipelines and orchestration
- A **data workspace** for the lakehouse and data layers

Each workspace will be properly configured with documentation, security controls, and capacity management to ensure optimal governance and maintainability.

## Key Concepts

### Workspace Configuration
- **Description**: Document the purpose and scope of each workspace for governance and team collaboration
- **Workspace Identity**: Enable secure, role-based access control to resources and services
- **Capacity Assignment**: Use parameters to dynamically assign compute capacity, making it easy to adjust resources without manual configuration changes

### Medallion Architecture
The Medallion Architecture organizes data into three progressively refined layers:
- `LH_Data_Landingzone`: Raw, unprocessed data ingestion layer
- `LH_Bronze_Layer`: Cleaned and standardized data layer
- `LH_Silver_Layer`: Aggregated and business-ready data layer

Each layer includes descriptive metadata identifying its purpose, data types, and expected use cases.

### Notebooks
Create a well-structured, empty notebook in the code workspace as a template for data ingestion and transformation workflows. This will serve as the foundation for subsequent exercises.

## Expected Outcome

✅ A documented, parameterized workspace structure
✅ A three-tier Medallion Architecture with clear data lineage
✅ A prepared notebook ready for data operations 

 
