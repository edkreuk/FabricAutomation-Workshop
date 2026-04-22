🧪 Exercise 1 – Environment & Architecture Setup 

Goal 

Set up a well-documented Fabric workspace and implement a Medallion Architecture using parameters

We need to have a workspace where we can store all our code and one where we want to store the lakehouse.
Every Workspace needs to have a clear description of its purpose. This is important for governance and maintenance.
For security and access control, we will assign a Workspace Identity to the workspace. This allows us to manage permissions and access to resources in a more secure way.
Every workspace needs to have a capacity assigned which is set by a parameter. This allows us to easily change the capacity if needed without having to go into the workspace settings.

The Medallion Architecture is a common data architecture pattern that organizes data into different layers based on its level of refinement and quality. The layers typically include:
'LH_Data_Landingzone','LH_Bronze_Layer','LH_Silver_Layer'

Every lakehouse should have a clear description of its purpose and the type of data it contains. This helps with governance and maintenance.

In the code we want to have an empty Notebook with a clear description of its purpose. Notebooks will be used for data ingestion and transformation in later exercises.

Tasks 

Workspace configuration 

Assign a Workspace Identity 

Add a clear workspace description describing purpose and ownership 

Medallion Architecture setup 

Design a Medallion Architecture with the following layers: 

LDZ – Landing Zone 

BRZ – Bronze 

SLV – Silver 

GLD – Gold 

Use parameters to drive naming and configuration 

Lakehouse creation & documentation 

Create a Lakehouse for each layer (LDZ, BRZ, SLV, GLD) 

Add a description to each Lakehouse explaining its role 

Notebook creation 

Create a new Notebook 

Add a clear Notebook description explaining its purpose in the platform 

✅ Outcome: A documented workspace, medallion-based lakehouse structure, and a prepared notebook. 

 
