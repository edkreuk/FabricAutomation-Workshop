🧪 Exercise 1 – Environment & Architecture Setup 

Goal 

Set up a well-documented Fabric workspace and implement a Medallion Architecture using parameters and metadata. 

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

 

🧪 Exercise 2 – Data Ingestion & Scheduling 

Goal 

Load data into the platform and automate refresh. 

Tasks 

Upload data 

Upload the provided LEGO data files to the appropriate landing area 

Notebook setup 

Download the provided Notebook 

Import or open it in your Fabric workspace 

Data loading 

Use the Notebook to load the uploaded data into the Lakehouse 

Scheduling 

Configure a scheduled data refresh for the Notebook 

✅ Outcome: Data is ingested into Fabric and refreshed automatically. 

 

🧪 Exercise 3 – Shortcuts & Dimensional Modeling 

Goal 

Reuse data efficiently using OneLake shortcuts and create dimensional structures. 

Tasks 

Create shortcuts 

Create OneLake shortcuts from Silver (SLV) to Gold (GLD) 

Dimensional model 

Run the provided Dimensional Model Notebook 

Generate dimension and fact tables in the Gold layer 

✅ Outcome: A Gold layer with dimensional tables built on reused Silver data. 

 

🧪 Exercise 4 – Semantic Model & Reporting 

Goal 

Expose curated data to business users through Power BI. 

Tasks 

Semantic Model (SM) 

Build a Semantic Model using the provided example Notebook 

Reporting 

Create a Power BI report on top of the Semantic Model 

Validate relationships, measures, and visuals 

✅ Outcome: A complete analytics experience from lakehouse to report. 

 

🧪 Exercise 5 – Variable Library & Reusability 

Goal 

Introduce configuration-driven development using variables. 

Tasks 

Variable Library 

Create a Variable Library for reusable configuration values 

Lakehouse reference 

Add Lakehouse references to the Variable Library 

Use these variables in your Notebooks 

✅ Outcome: A more maintainable, metadata-driven and reusable platform setup. 

 

🏁 Workshop Completion 

By the end of this workshop you will have: 

A documented Fabric workspace 

A parameter-driven Medallion Architecture 

Automated ingestion and refresh 

Dimensional Gold models 

A Semantic Model and Power BI report 

A Variable Library enabling platform engineering patterns 

 

🚀 Next Steps (Optional) 

Extend metadata-driven patterns 

Add data quality or observability checks 

Integrate CI/CD and Git 

Secure data using OneLake and Purview 

Happy building! 💡 
