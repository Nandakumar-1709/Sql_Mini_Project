/* ==========================================================================
   PROJECT : Company salary vs country salary benchmark (by job role)
   GOAL    : For each country + job role, show which companies pay
             below, within, or above the typical market range, so a job
             seeker knows which companies to target.

   FLOW    : filters  ->  country_role_stats  ->  company_role_salary
             ->  final SELECT (joins the two CTEs, applies filters)

   HOW TO USE: edit only the 'filters' block below, then run the query.
   ========================================================================== */


-- STEP 0: SETTINGS PANEL (one row; the final WHERE clause reads these)
WITH filters AS (
    SELECT
        NULL::text AS f_country,   -- 'India' to filter; NULL = all countries
        NULL::text AS f_title,     -- 'Data Analyst' to filter; NULL = all roles
        1          AS min_jobs     -- min postings per company; 1 = hide nothing
),


-- STEP 1: COUNTRY BENCHMARK
-- For each country + role, use ALL postings with a salary to find the
-- "normal" market range: q1 (25th pct), median, q3 (75th pct), iqr, job_count.
country_role_stats AS (
    SELECT 
        job_country, 
        job_title_short, 
        COUNT(job_id) AS job_count, 

        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_year_avg) AS q1,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salary_year_avg) AS median_salary,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_year_avg) AS q3,

        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_year_avg)
        - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_year_avg) AS iqr

    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_country, job_title_short
),


-- STEP 2: COMPANY SALARY
-- For each country + company + role: the company's median salary and
-- how many postings it is based on.
company_role_salary AS (
    SELECT 
        job.job_country,
        job.company_id,
        comp.name AS company_name,
        job.job_title_short AS job_title,
        COUNT(job.job_id) AS company_job_count,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY job.salary_year_avg) AS median_salary

    FROM job_postings_fact AS job
    INNER JOIN company_dim AS comp 
        ON job.company_id = comp.company_id
    WHERE job.salary_year_avg IS NOT NULL
    GROUP BY job.job_country, job.company_id, comp.name, job.job_title_short
)


-- STEP 3: FINAL RESULT (user-friendly view)
-- Commented-out columns are still calculated above; remove the "--" to show them.
SELECT 
    -- ---- Shown by default ----
    c.job_country AS country,
    c.company_name,
    c.job_title,
    ROUND(c.median_salary::numeric, 2) AS median_salary,        -- company's median salary

    -- How far the company is from the country median (+ above, - below)
    ROUND((c.median_salary - s.median_salary)::numeric, 2)
        AS diff_from_country_median,

    -- Where the company sits in the country range
    CASE
        WHEN c.median_salary < s.q1 THEN 'Lower Than Country Standard'   -- below 25th pct
        WHEN c.median_salary > s.q3 THEN 'Higher Than Country Standard'  -- above 75th pct
        ELSE 'Country Standard'                                          -- in between
    END AS salary_category,

    -- Trust label: companies with very few postings are unreliable
    CASE
        WHEN c.company_job_count < 3 THEN 'Low sample'
        ELSE 'OK'
    END AS sample_size_flag

    -- ---- Hidden for now (uncomment for deeper analysis) ----
    -- NOTE: to use any of these, add a comma after 'sample_size_flag' above.
    -- , c.company_job_count AS company_job_count                     -- postings behind company median
    -- , s.job_count AS country_role_job_count                        -- postings behind country benchmark
    -- , ROUND(s.median_salary::numeric, 2) AS country_median_salary  -- country median
    -- , ROUND(s.q1::numeric, 2) AS country_q1                        -- country low-end benchmark
    -- , ROUND(s.q3::numeric, 2) AS country_q3                        -- country high-end benchmark
    -- , ROUND(s.iqr::numeric, 2) AS country_iqr                      -- country spread

FROM company_role_salary AS c

-- Match each company row to its country + role benchmark
INNER JOIN country_role_stats AS s 
    ON c.job_country = s.job_country 
    AND c.job_title  = s.job_title_short

-- Copy the single settings row onto every result row so WHERE can use it
CROSS JOIN filters AS f

-- FILTERS: "no filter set (NULL) OR row matches"
WHERE (f.f_country IS NULL OR c.job_country = f.f_country)
  AND (f.f_title   IS NULL OR c.job_title   = f.f_title)
  AND c.company_job_count >= f.min_jobs

-- Group by country, highest-paying companies first
ORDER BY 
    c.job_country,
    c.median_salary DESC;