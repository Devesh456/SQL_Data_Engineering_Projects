# Data Engineer Skills: Exploratory Data Analysis (SQL)

An exploratory analysis of the **remote Data Engineer job market**, using SQL to answer one practical question: *which skills are worth learning?*

The project looks at skills from three angles, then combines them:

1. **Demand**: which skills appear most often in postings?
2. **Pay**: which skills are associated with the highest salaries?
3. **Value**: which skills balance both?

---

## Repository Structure

```
.
├── 1_top_demanded_skills.sql   # Most in-demand skills
├── 2_top_paying_skills.sql     # Highest-paying skills (with demand count)
├── 3_optimal_skills.sql        # Combined demand + salary ranking
└── README.md
```

---

## Data Model

All three queries use the same three tables:

| Table | Role | Columns used |
|---|---|---|
| `job_postings_fact` | One row per job posting | `job_id`, `job_title_short`, `job_work_from_home`, `salary_year_avg` |
| `skills_job_dim` | Bridge table linking postings to skills (many-to-many) | `job_id`, `skill_id` |
| `skills_dim` | Skill lookup | `skill_id`, `skills` |

**Common filters**

- `job_title_short = 'Data Engineer'`
- `job_work_from_home = True` (remote roles only)

**Join pattern**

```
job_postings_fact ──(job_id)──> skills_job_dim ──(skill_id)──> skills_dim
```

> The query syntax (`MEDIAN`, `LN`, and the box-drawing result tables) is DuckDB-style. Other engines may need small changes, for example `PERCENTILE_CONT(0.5)` in place of `MEDIAN`.

---

## Analysis Walkthrough

### 1. Top Demanded Skills: `1_top_demanded_skills.sql`

**Question:** What are the most in-demand skills for remote data engineers?

**Approach:** Join postings to skills, filter to remote Data Engineer roles, count postings per skill, and keep the top 10.

| Skill | Postings |
|---|---:|
| sql | 29,221 |
| python | 28,776 |
| aws | 17,823 |
| azure | 14,143 |
| spark | 12,799 |
| airflow | 9,996 |
| snowflake | 8,639 |
| databricks | 8,183 |
| java | 7,267 |
| gcp | 6,446 |

**Takeaway:** SQL and Python are close to universal. Cloud platforms (AWS, Azure, GCP) and big-data/orchestration tools (Spark, Airflow, Snowflake, Databricks) make up the rest of the core stack.

---

### 2. Top Paying Skills: `2_top_paying_skills.sql`

**Question:** Which skills are associated with the highest median salaries?

**Approach:** Compute the median `salary_year_avg` per skill, show a demand count alongside it, keep skills with more than 100 postings, and return the top 24 by median salary.

Top 10 shown below (full output is in the SQL file):

| Skill | Median Salary | Postings |
|---|---:|---:|
| rust | $210,000 | 232 |
| golang | $184,000 | 912 |
| terraform | $184,000 | 3,248 |
| spring | $175,500 | 364 |
| neo4j | $170,000 | 277 |
| gdpr | $169,616 | 582 |
| zoom | $168,438 | 127 |
| graphql | $167,500 | 445 |
| mongo | $162,250 | 265 |
| fastapi | $157,500 | 204 |

**Takeaway:** The top of the list favors specialized, software-engineering-leaning skills (Rust, Go, Spring) and infrastructure tooling (Terraform, Kubernetes, Ansible). Some entries (`zoom`, `gdpr`, `crystal`) are unlikely to cause higher pay and probably reflect which postings happen to mention them. Treat the highest medians as signals, not rules.

---

### 3. Optimal Skills: `3_optimal_skills.sql`

**Question:** Which skills balance demand and salary?

**Approach:** Restrict to remote Data Engineer postings **with a stated salary**, then score each skill:

```
skill_value = (median_salary × ln(demand_cnt)) / 100,000
```

The natural log dampens raw demand, so a skill with 10× the postings isn't scored 10× higher. This keeps very common skills from swamping everything while still rewarding skills that are both well paid and widely requested. Skills with 100 or fewer salaried postings are excluded.

Top 10 shown below (full output is in the SQL file):

| Rank | Skill | Median Salary | Salaried Postings | Skill Value |
|---:|---|---:|---:|---:|
| 1 | terraform | $184,000 | 193 | 9.68 |
| 2 | python | $135,000 | 1,133 | 9.49 |
| 3 | aws | $137,320 | 783 | 9.15 |
| 4 | sql | $130,000 | 1,128 | 9.14 |
| 5 | airflow | $150,000 | 386 | 8.93 |
| 6 | spark | $140,000 | 503 | 8.71 |
| 7 | snowflake | $135,500 | 438 | 8.24 |
| 8 | kafka | $145,000 | 292 | 8.23 |
| 9 | azure | $128,000 | 475 | 7.89 |
| 10 | java | $135,000 | 303 | 7.71 |

**Takeaway:** Python, SQL and AWS stay near the top once salary is factored in. **Terraform** ranks first because of its strong pay premium. Rarer high-paying skills like Rust fall out of the ranking, since they don't meet the sample-size threshold once restricted to postings with salary data.

---

## Key Findings

- **Foundations:** SQL and Python lead in demand and remain top-ranked on combined value.
- **Cloud and pipelines:** AWS, Spark and Airflow are consistently strong. Azure and GCP are highly demanded but pay slightly less at the median.
- **Best pay premium for the core stack:** Terraform (infrastructure-as-code) is the strongest differentiator, ranking 1st in combined value at a median of $184K.
- **Worth adding:** Kafka, Kubernetes and Scala show up with higher medians ($137K to $150K) at moderate demand.

---

## Methodology Notes and Limitations

- **Query 2's demand count is not salary-filtered.** It uses `COUNT(jpf.*)` with no `salary_year_avg IS NOT NULL` filter, so `demand_cnt` counts *all* remote postings for a skill (for example, Airflow's 9,996 matches Query 1). The median ignores NULL salaries, so it is still computed only on salaried rows, but the `HAVING demand_cnt > 100` threshold does not guarantee enough *salaried* postings. Query 3 fixes this by filtering to non-null salaries first.
- **Salary coverage is partial.** Many postings have no salary, so median figures represent a subset of the market and may skew toward employers that disclose pay.
- **Skills co-occur.** A posting listing Python, AWS and Terraform counts toward all three. A skill's median salary reflects the *kind of job* that asks for it, not the pay uplift from learning that skill alone.
- **`skill_value` is a heuristic.** The log-weighted score and the `/100000` scaling are design choices. Different weightings would reorder the middle of the ranking.
- **Minimum threshold.** The `> 100` cutoff removes noisy, low-sample skills but also hides genuinely niche ones.
- **Static snapshot.** Results reflect the dataset as loaded and are not a live market view.

---

## How to Run

1. Load the three tables (`job_postings_fact`, `skills_job_dim`, `skills_dim`) into DuckDB (or adapt to your SQL engine).
2. Run each script in order:

```bash
duckdb data_jobs.duckdb < 1_top_demanded_skills.sql
duckdb data_jobs.duckdb < 2_top_paying_skills.sql
duckdb data_jobs.duckdb < 3_optimal_skills.sql
```

Each file includes its result table in a trailing comment block for reference.

---

## Possible Next Steps

- Filter Query 2 to salaried postings so its demand counts match Query 3.
- Compare remote vs. on-site or by country/region.
- Track skill demand and salary over time using posting dates.
- Group skills into categories (cloud, languages, orchestration, databases) and analyze by category.
- Test alternative scoring formulas (for example, a z-score blend) against the log-weighted ranking.
- Repeat for other roles such as Data Analyst or Data Scientist.
