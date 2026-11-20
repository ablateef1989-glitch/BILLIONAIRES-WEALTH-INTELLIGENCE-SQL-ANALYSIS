-- THE BILLIONAIRE WEALTH INVESTIGATION
-- SQL analysis of the Top 200 Richest Person in the World dataset
-- SQL dialect: SQLite-compatible standard SQL
--
-- Dataset columns:
-- serial_number, rank, name, age, country,
-- networth_billion_US_dollars, industry
--
-- Import the supplied CSV into a table named: billionaires
-- Ensure networth_billion_US_dollars is stored as a numeric value.
-- The script is organised as follows:
--   Section 1: data checks and cleaning
--   Section 2: the ten required business questions
--   Section 3: additional portfolio analyses
--
-- Portability notes:
--   * MySQL 8: RANK is a reserved word, so write `rank` with backticks.
--   * SQL Server: replace LIMIT n with SELECT TOP n.


-- ============================================================
-- SECTION 1: DATA CHECKS AND CLEANING
-- ============================================================

-- Check the number of records (expected: 200)
SELECT COUNT(*) AS total_records
FROM billionaires;


-- Check for leading or trailing spaces in text columns (expected before cleaning: 2 rows)
SELECT serial_number, name, country
FROM billionaires
WHERE country <> TRIM(country)
   OR industry <> TRIM(industry)
   OR name <> TRIM(name);


-- Clean the text columns
-- Without this step 'China ' and 'China' (and ' Brazil' and 'Brazil')
-- are treated as different countries by GROUP BY.
UPDATE billionaires
SET country  = TRIM(country),
    industry = TRIM(industry),
    name     = TRIM(name);


-- Re-run the check (expected after cleaning: no rows)
SELECT serial_number, name, country
FROM billionaires
WHERE country <> TRIM(country)
   OR industry <> TRIM(industry)
   OR name <> TRIM(name);


-- Check for missing values (expected: 0 in every column)
SELECT COUNT(*) - COUNT(name)                        AS missing_name,
       COUNT(*) - COUNT(age)                         AS missing_age,
       COUNT(*) - COUNT(country)                     AS missing_country,
       COUNT(*) - COUNT(networth_billion_US_dollars) AS missing_net_worth,
       COUNT(*) - COUNT(industry)                    AS missing_industry
FROM billionaires;


-- Check for duplicate names (expected: no rows)
SELECT name, COUNT(*) AS occurrences
FROM billionaires
GROUP BY name
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 2: BUSINESS QUESTIONS
-- ============================================================

-- Q1. Retrieve the 20 richest billionaires
SELECT rank, name, age, country, networth_billion_US_dollars AS net_worth_billions, industry
FROM billionaires
ORDER BY networth_billion_US_dollars DESC, rank ASC
LIMIT 20;


-- Q2. Identify the five youngest billionaires
SELECT name, age, country, rank, networth_billion_US_dollars AS net_worth_billions, industry
FROM billionaires
ORDER BY age ASC, networth_billion_US_dollars DESC
LIMIT 5;


-- Q3. Calculate average age and average net worth
SELECT ROUND(AVG(age), 2) AS average_age_years,
       ROUND(AVG(networth_billion_US_dollars), 2) AS average_net_worth_billions
FROM billionaires;


-- Q4. Identify the five most represented countries
SELECT country, COUNT(*) AS billionaire_count
FROM billionaires
GROUP BY country
ORDER BY billionaire_count DESC, country ASC
LIMIT 5;


-- Q5. Calculate combined net worth by country
SELECT country, COUNT(*) AS billionaire_count,
       ROUND(SUM(networth_billion_US_dollars), 2) AS combined_net_worth_billions
FROM billionaires
GROUP BY country
ORDER BY combined_net_worth_billions DESC;


-- Q6. Identify the five industries with the highest number of billionaires
SELECT industry, COUNT(*) AS billionaire_count
FROM billionaires
GROUP BY industry
ORDER BY billionaire_count DESC, industry ASC
LIMIT 5;


-- Q7. Find countries with at least five billionaires
SELECT country, COUNT(*) AS billionaire_count,
       ROUND(SUM(networth_billion_US_dollars), 2) AS combined_net_worth_billions
FROM billionaires
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY billionaire_count DESC, combined_net_worth_billions DESC;


-- Q8. Calculate total wealth of billionaires younger than 50
SELECT COUNT(*) AS billionaire_count,
       ROUND(SUM(networth_billion_US_dollars), 2) AS total_net_worth_billions
FROM billionaires
WHERE age < 50;


-- Q9. Identify billionaires whose net worth exceeds the overall average
SELECT name, age, country, networth_billion_US_dollars AS net_worth_billions, industry
FROM billionaires
WHERE networth_billion_US_dollars >
      (SELECT AVG(networth_billion_US_dollars) FROM billionaires)
ORDER BY networth_billion_US_dollars DESC;


-- Q9 (count). Number of billionaires above the overall average
SELECT COUNT(*) AS above_average_count
FROM billionaires
WHERE networth_billion_US_dollars >
      (SELECT AVG(networth_billion_US_dollars) FROM billionaires);


-- Q10. Identify the industry with the highest average net worth
-- All industries are listed so the group sizes can be seen.
-- Telecom ranks first but contains only one billionaire.
SELECT industry, COUNT(*) AS billionaire_count,
       ROUND(AVG(networth_billion_US_dollars), 2) AS average_net_worth_billions
FROM billionaires
GROUP BY industry
ORDER BY average_net_worth_billions DESC;


-- Q10 (check). Same comparison, industries with at least five billionaires
SELECT industry, COUNT(*) AS billionaire_count,
       ROUND(AVG(networth_billion_US_dollars), 2) AS average_net_worth_billions
FROM billionaires
GROUP BY industry
HAVING COUNT(*) >= 5
ORDER BY average_net_worth_billions DESC;


-- ============================================================
-- SECTION 3: ADDITIONAL ANALYSES
-- ============================================================

-- Overall wealth and population summary
SELECT COUNT(*) AS total_billionaires,
       ROUND(SUM(networth_billion_US_dollars), 2) AS total_net_worth_billions,
       ROUND(AVG(age), 2) AS average_age,
       ROUND(MIN(networth_billion_US_dollars), 2) AS lowest_net_worth_billions,
       ROUND(MAX(networth_billion_US_dollars), 2) AS highest_net_worth_billions
FROM billionaires;


-- Median net worth (average of the 100th and 101st values)
SELECT ROUND(AVG(networth_billion_US_dollars), 2) AS median_net_worth_billions
FROM (SELECT networth_billion_US_dollars
      FROM billionaires
      ORDER BY networth_billion_US_dollars
      LIMIT 2 OFFSET 99) AS middle_two;


-- Wealth concentration by industry
SELECT industry, COUNT(*) AS billionaire_count,
       ROUND(SUM(networth_billion_US_dollars), 2) AS total_net_worth_billions,
       ROUND(AVG(networth_billion_US_dollars), 2) AS average_net_worth_billions
FROM billionaires
GROUP BY industry
ORDER BY total_net_worth_billions DESC;


-- Billionaires by age group
SELECT CASE
         WHEN age < 40 THEN 'Under 40'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         WHEN age BETWEEN 50 AND 59 THEN '50-59'
         WHEN age BETWEEN 60 AND 69 THEN '60-69'
         WHEN age BETWEEN 70 AND 79 THEN '70-79'
         ELSE '80 and above'
       END AS age_group,
       COUNT(*) AS billionaire_count,
       ROUND(SUM(networth_billion_US_dollars), 2) AS total_net_worth_billions
FROM billionaires
GROUP BY age_group
ORDER BY MIN(age);


-- Share of total wealth held by the top 10
SELECT ROUND(SUM(networth_billion_US_dollars), 2) AS top_10_net_worth_billions,
       ROUND(100.0 * SUM(networth_billion_US_dollars) /
             (SELECT SUM(networth_billion_US_dollars) FROM billionaires), 2) AS share_of_total_wealth_percent
FROM (SELECT networth_billion_US_dollars
      FROM billionaires
      ORDER BY networth_billion_US_dollars DESC
      LIMIT 10) AS top_10;


-- Number of countries represented (expected after cleaning: 35)
SELECT COUNT(DISTINCT country) AS countries_represented
FROM billionaires;
