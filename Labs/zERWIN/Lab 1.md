# 🧪 Exercise 1 – Environment & Architecture Setup

## 🎯 Goal

Set up a well-documented Fabric workspace and implement a **Medallion Architecture** using parameters and metadata.

---

## 📋 Tasks

### 1. Workspace configuration

- Assign a **Workspace Identity**
- Add a clear **workspace description** describing purpose and ownership

---

### 2. Medallion Architecture setup

Design a Medallion Architecture with the following layers:

| Layer | Code | Purpose |
|-------|------|---------|
| Landing Zone | `LDZ` | Raw, unmodified data as ingested from source |
| Bronze | `BRZ` | Cleansed and standardized raw data |
| Silver | `SLV` | Conformed, business-ready data |
| Gold | `GLD` | Aggregated and analytics-ready data |

> 💡 Use **parameters** to drive naming and configuration.

---

### 3. Lakehouse creation & documentation

- Create a **Lakehouse** for each layer (`LDZ`, `BRZ`, `SLV`, `GLD`)
- Add a **description** to each Lakehouse explaining its role

---

### 4. Notebook creation

- Create a new **Notebook**
- Add a clear **Notebook description** explaining its purpose in the platform

---

## ✅ Outcome

A documented workspace, a medallion-based lakehouse structure, and a prepared notebook — all ready for the next exercise.
