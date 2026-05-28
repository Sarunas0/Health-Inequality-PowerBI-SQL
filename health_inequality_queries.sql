USE HealthInequalityBI;
GO

/* =====================================================
   Health Inequality SQL + Power BI Project
   Author: Sarunas Surdokas
   Purpose: Clean, structure, and query health inequality
            data for Power BI dashboard analysis.
   ===================================================== */


/* 1. Inspect source tables */

SELECT TOP 10 *
FROM stg.health_index_raw;

SELECT TOP 10 *
FROM stg.healthy_life_expectancy_raw;

SELECT TOP 10 *
FROM stg.imd_lsoa_raw;

SELECT TOP 10 *
FROM wh.dim_health_area;

SELECT TOP 10 *
FROM wh.dim_lsoa_area;

SELECT TOP 10 *
FROM wh.fact_health_index;

SELECT TOP 10 *
FROM wh.fact_deprivation_lsoa;


/* 2. Health index trend by year */

SELECT
    h.year,
    AVG(h.health_index_score) AS avg_health_index_score
FROM wh.fact_health_index h
GROUP BY h.year
ORDER BY h.year;


/* 3. Health index by area type */

SELECT
    a.area_type,
    h.year,
    AVG(h.health_index_score) AS avg_health_index_score
FROM wh.fact_health_index h
JOIN wh.dim_health_area a
    ON h.area_code = a.area_code
GROUP BY
    a.area_type,
    h.year
ORDER BY
    a.area_type,
    h.year;


/* 4. Change in health index since 2015 */

WITH base_year AS (
    SELECT
        area_code,
        health_index_score AS score_2015
    FROM wh.fact_health_index
    WHERE year = 2015
),
latest_year AS (
    SELECT
        area_code,
        health_index_score AS score_2021
    FROM wh.fact_health_index
    WHERE year = 2021
)
SELECT
    a.area_type,
    AVG(l.score_2021 - b.score_2015) AS avg_change_since_2015
FROM base_year b
JOIN latest_year l
    ON b.area_code = l.area_code
JOIN wh.dim_health_area a
    ON b.area_code = a.area_code
GROUP BY a.area_type
ORDER BY avg_change_since_2015 DESC;


/* 5. Deprivation by LSOA */

SELECT
    l.lsoa_code,
    AVG(d.imd_score) AS avg_imd_score,
    AVG(d.imd_rank) AS avg_imd_rank,
    AVG(d.imd_decile) AS avg_imd_decile
FROM wh.fact_deprivation_lsoa d
JOIN wh.dim_lsoa_area l
    ON d.lsoa_code = l.lsoa_code
GROUP BY
    l.lsoa_code
ORDER BY avg_imd_score DESC;


/* 6. Final analytical table for Power BI */

SELECT
    h.area_code,
    a.area_name,
    a.area_type,
    h.year,
    h.health_index_score
FROM wh.fact_health_index h
JOIN wh.dim_health_area a
    ON h.area_code = a.area_code
ORDER BY
    h.year,
    a.area_name;

/* 7. Top 20 most deprived LSOAs */

SELECT TOP 20
    d.lsoa_code,
    AVG(d.imd_score) AS avg_imd_score,
    AVG(d.imd_rank) AS avg_imd_rank,
    AVG(d.imd_decile) AS avg_imd_decile
FROM wh.fact_deprivation_lsoa d
GROUP BY
    d.lsoa_code
ORDER BY avg_imd_score DESC;

/* 8. Top 20 highest health index areas */

SELECT TOP 20
    a.area_name,
    AVG(h.health_index_score) AS avg_health_index_score
FROM wh.fact_health_index h
JOIN wh.dim_health_area a
    ON h.area_code = a.area_code
GROUP BY a.area_name
ORDER BY avg_health_index_score DESC;