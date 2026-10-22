# SQL Projects

A collection of SQL projects covering exploratory data analysis, querying, and database design. Each project lives in its own folder with its own scripts and documentation.

## Projects

| # | Project | Description | Skills Demonstrated | Dialect |
|---|---------|-------------|---------------------|---------|
| 1 | [Data Engineer Skills: Exploratory Data Analysis](./EDA) | Analyses the remote Data Engineer job market to find which skills are worth learning, by demand, pay, and a combined value score | Multi-table joins, aggregation, `MEDIAN`, `HAVING`, log-weighted scoring | DuckDB |
| 2 | *Coming soon* | | | |
| 3 | *Coming soon* | | | |

## Repository Structure

```
sql-projects/
├── README.md
├── project-1-data-engineer-skills/
│   ├── 1_top_demanded_skills.sql
│   ├── 2_top_paying_skills.sql
│   ├── 3_optimal_skills.sql
│   └── README.md          # Full write-up, results, and limitations
├── project-2-name/
└── project-3-name/
```

## Getting Started

### Prerequisites

- [DuckDB](https://duckdb.org/) (used for Project 1). Other engines may need small syntax changes, which each project README notes.
- Any SQL client you prefer, or the DuckDB command line.

### Running a Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Devesh456/EDA.git
   cd <repo-name>
   ```
2. Open the project folder you want to explore.
3. Load the project's data as described in its README.
4. Run the scripts in numbered order.

Each project's own README has the exact steps and any project-specific notes.

## Project Summaries

### 1. Data Engineer Skills: Exploratory Data Analysis

**Goal:** Work out which skills are worth learning for remote Data Engineer roles by looking at demand, pay, and a combination of both.

**Dataset:** Job postings data across three tables: `job_postings_fact`, `skills_job_dim` (a many-to-many bridge table), and `skills_dim`. Queries are filtered to remote Data Engineer postings.

**What I did:**
- Ranked skills by number of postings (demand)
- Ranked skills by median salary, with a demand count alongside
- Built a combined `skill_value` score: `(median_salary × ln(demand_cnt)) / 100,000`, restricted to postings with a stated salary

**Key findings:**
- SQL and Python lead in demand and stay near the top once salary is factored in.
- Terraform ranks first on combined value, with a median salary of $184K.
- Kafka, Kubernetes and Scala are worth adding, with higher medians at moderate demand.

[View the full project 1→](/EDA)

### 2. Project Name *(coming soon)*

### 3. Project Name *(coming soon)*

## Skills & Concepts Covered

- Joining across fact, dimension, and bridge tables
- Filtering, sorting, and aggregation (`WHERE`, `GROUP BY`, `HAVING`)
- Statistical aggregates (`MEDIAN`) and handling `NULL` salary data
- Building composite scoring metrics (log-weighted demand and salary)
- Interpreting results and documenting limitations

## About

Built by **[Devesh Simariya]**

