/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
    COUNT(jpf.salary_year_avg) AS demand_cnt,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.salary_year_avg))) / 100000, 2) AS skill_value
FROM    
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Engineer' 
    AND jpf.job_work_from_home = True 
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY
    sd.skills
HAVING
    demand_cnt > 100
ORDER BY 
    skill_value DESC
LIMIT 
    24;

/*

┌────────────┬───────────────┬────────────┬─────────────┐
│   skills   │ median_salary │ demand_cnt │ skill_value │
│  varchar   │    double     │   int64    │   double    │
├────────────┼───────────────┼────────────┼─────────────┤
│ terraform  │      184000.0 │        193 │        9.68 │
│ python     │      135000.0 │       1133 │        9.49 │
│ aws        │      137320.0 │        783 │        9.15 │
│ sql        │      130000.0 │       1128 │        9.14 │
│ airflow    │      150000.0 │        386 │        8.93 │
│ spark      │      140000.0 │        503 │        8.71 │
│ snowflake  │      135500.0 │        438 │        8.24 │
│ kafka      │      145000.0 │        292 │        8.23 │
│ azure      │      128000.0 │        475 │        7.89 │
│ java       │      135000.0 │        303 │        7.71 │
│ scala      │      137290.0 │        247 │        7.56 │
│ kubernetes │      150500.0 │        147 │        7.51 │
│ git        │      140000.0 │        208 │        7.47 │
│ databricks │      132750.0 │        266 │        7.41 │
│ redshift   │      130000.0 │        274 │         7.3 │
│ gcp        │      136000.0 │        196 │        7.18 │
│ hadoop     │      135000.0 │        198 │        7.14 │
│ nosql      │      134415.0 │        193 │        7.07 │
│ pyspark    │      140000.0 │        152 │        7.03 │
│ docker     │      135000.0 │        144 │        6.71 │
│ mongodb    │      135750.0 │        136 │        6.67 │
│ go         │      140000.0 │        113 │        6.62 │
│ r          │      134775.0 │        133 │        6.59 │
│ github     │      135000.0 │        127 │        6.54 │
└────────────┴───────────────┴────────────┴─────────────┘

*/