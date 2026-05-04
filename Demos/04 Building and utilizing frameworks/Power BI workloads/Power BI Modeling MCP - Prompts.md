# Power BI Modeling MCP — Prompt walkthrough

Same outcome as the Semantic Link Labs notebook in this folder — a Direct Lake semantic model over the gold lakehouse with relationships, measures, and a Time Intelligence calc group — but driven **agentically** through the [Power BI Modeling MCP](https://github.com/microsoft/powerbi-modeling-mcp) from VS Code.

The model gets built; **no report** is created here. Pair this with the autogen-report notebook if you want to demo the full flow.

> ⚠️ **Untested by me before the session.** Verify the install steps and tool names against the latest README of the MCP server before running live — Microsoft is iterating on this fast.

---

## 0. One-time setup

1. Install the **Power BI Modeling MCP** server per the [official README](https://github.com/microsoft/powerbi-modeling-mcp).
2. Register it in VS Code (`.vscode/mcp.json` or the GitHub Copilot Chat MCP UI).
3. Sign in to Power BI / Fabric using the auth flow the MCP exposes (typically interactive browser).
4. Open Copilot Chat in **Agent** mode so it can actually call the MCP tools.

Sanity check before the demo:

> List the Power BI workspaces I have access to using the Power BI Modeling MCP, and show the lakehouses inside the workspace named `<your-workspace>`.

If that returns the lakehouse you expect, you're good.

---

## 1. Discover the gold lakehouse

> Using the Power BI Modeling MCP, connect to the workspace `<your-workspace>` and list every Delta table in the lakehouse `<your-lakehouse>`. For each table, show its column names and data types. Group the result into three sections: **Dimensions** (tables prefixed `dim_`), **Facts** (prefixed `fact_`), and **Other** (everything else).

Goal: confirm the agent can read the lakehouse contents and apply the same dim/fact convention the notebook uses.

---

## 2. Bootstrap a Direct Lake semantic model

> Create a new Direct Lake semantic model called `Sales - MCP Generated` in the workspace `<your-workspace>`, using the lakehouse `<your-lakehouse>` as the source. Include all `dim_*` and `fact_*` tables you found. Skip the rest. Refresh the model after creating it, and confirm it has been created.

If the MCP exposes a single "create Direct Lake model" tool, this should be one call. If it only exposes lower-level model-edit tools, the agent will sequence the steps for you — that's the whole point.

---

## 3. Add relationships from key suffixes

> For every `fact_*` table in the `Sales - MCP Generated` model, find the columns ending in `_id` or `_key`. For each one, create a many-to-one relationship to the matching dimension table. Match the dimension by name — for example `customer_id` on a fact links to `dim_customer`'s primary key (also `_id` / `_key`). Skip and report any keys you can't resolve.

Have the agent **print the resolved relationships before applying them** so you can verify on stage:

> Before creating the relationships, list them as a markdown table: from-table, from-column, to-table, to-column. Wait for me to confirm before applying.

---

## 4. Add generic measures

> On every fact table, add:
> 1. A measure named `# <fact_table>` with expression `COUNTROWS('<fact_table>')`, formatted `#,0`.
> 2. A `Total <Column>` measure for every numeric column that is *not* a key column (`_id` / `_key`), using `SUM('<fact>'[<column>])`, formatted `#,0.00`.
>
> Use the column's title-cased name (replace `_` with space) for the measure name.

---

## 5. Add the Time Intelligence calculation group

> Mark `dim_date[Date]` as the date table.
>
> Then add a calculation group called **Time Intelligence** with `precedence` 1 and these calculation items (in this ordinal order):
>
> | Ordinal | Name | Expression |
> |---|---|---|
> | 0 | Current | `SELECTEDMEASURE()` |
> | 10 | YTD | `CALCULATE(SELECTEDMEASURE(), DATESYTD('dim_date'[Date]))` |
> | 20 | QTD | `CALCULATE(SELECTEDMEASURE(), DATESQTD('dim_date'[Date]))` |
> | 30 | MTD | `CALCULATE(SELECTEDMEASURE(), DATESMTD('dim_date'[Date]))` |
> | 40 | PY | `CALCULATE(SELECTEDMEASURE(), SAMEPERIODLASTYEAR('dim_date'[Date]))` |
> | 50 | PY YTD | `CALCULATE(SELECTEDMEASURE(), SAMEPERIODLASTYEAR(DATESYTD('dim_date'[Date])))` |
> | 60 | YoY | `SELECTEDMEASURE() - CALCULATE(SELECTEDMEASURE(), 'Time Intelligence'[Time Intelligence] = "PY")` |
> | 70 | YoY % | `DIVIDE(CALCULATE(SELECTEDMEASURE(), 'Time Intelligence'[Time Intelligence] = "YoY"), CALCULATE(SELECTEDMEASURE(), 'Time Intelligence'[Time Intelligence] = "PY"))` |

---

## 6. Validate

> Run a small DAX query against `Sales - MCP Generated` that returns total amount for the latest year and the YoY % calc item value, and show me the result. Then summarise the model: number of tables, relationships, measures, and calc items.

This is the "did it actually work" cell — equivalent to opening the model in Power BI and clicking around, but inline in chat.

---

## 7. (Optional) Iterate naturally

A few free-form prompts that show why the agentic flow is interesting once the model exists:

> Rename `# fact_sales` to `Sales Count` and reformat it as a whole number with thousand separator.

> Add a measure `Average Order Value` on `fact_sales` as `DIVIDE([Total Amount], [Sales Count])`, formatted as currency.

> Hide every `_id` / `_key` column in the model — they should not show up in the field list.

> Move every base measure on `fact_sales` into a display folder called `Base measures`, and put any `Total *` measure into `Amounts`.

These are the demos that land — the model is built, and now you're refactoring it conversationally instead of clicking through the modeling pane.

---

## Live-demo checklist

- [ ] MCP server installed and visible in Copilot Chat (`/mcp` shows it)
- [ ] Auth completed (test with the workspace-list prompt above)
- [ ] Lakehouse exists with `dim_*` / `fact_*` tables
- [ ] Target workspace exists and is empty (or you're OK with `Sales - MCP Generated` overwriting)
- [ ] You've run the steps **once** before going live so you know which prompts the agent confidently executes one-shot vs. needs nudging
