-- Explatory Data Analysis

-- Use the database
USE world_layoffs;

-- Basic data check
SELECT *
FROM layoffs_staging2;

-- Maximum layoffs recorded
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies with 100% layoffs
SELECT *
FROM layoffs_staging2
Where percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- Comparing total layoffs with different columns 
SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
Order by 2 DESC;

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;


SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
Order by 2 DESC;

SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
Order by 2 DESC;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
Order by 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
Order by 2 DESC;

-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

-- layoff by year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling 3-Month Layoff Trends
WITH Rolling_Avg AS (
    SELECT 
        SUBSTRING(`date`,1,7) AS month,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    GROUP BY month
)
SELECT 
    month,
    monthly_layoffs,
    ROUND(AVG(monthly_layoffs) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3_month_avg
FROM Rolling_Avg;

-- Layoff Recovery Analysis (Companies That Hired Back)
WITH Company_Layoffs AS (
    SELECT 
        company, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, year
),
Company_Recoveries AS (
    SELECT 
        company, 
        year, 
        total_laid_off, 
        LAG(total_laid_off) OVER (PARTITION BY company ORDER BY year) AS previous_year_layoffs
    FROM Company_Layoffs
)
SELECT 
    company, 
    year, 
    total_laid_off, 
    previous_year_layoffs, 
    (previous_year_layoffs - total_laid_off) AS layoffs_recovered
FROM Company_Recoveries
WHERE previous_year_layoffs IS NOT NULL
ORDER BY layoffs_recovered DESC;

-- Finding which industry had the worst layoffs year-over-year
WITH Industry_Layoffs AS (
    SELECT 
        industry, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY industry, year
),
Industry_Changes AS (
    SELECT 
        industry, 
        year, 
        total_laid_off, 
        LAG(total_laid_off) OVER (PARTITION BY industry ORDER BY year) AS previous_year_layoffs,
        (total_laid_off - LAG(total_laid_off) OVER (PARTITION BY industry ORDER BY year)) AS YoY_Change
    FROM Industry_Layoffs
)
SELECT * FROM Industry_Changes
ORDER BY YoY_Change DESC;

-- percentage of total layoffs by country
WITH Country_Share AS (
    SELECT 
        country, 
        SUM(total_laid_off) AS country_layoffs, 
        (SUM(total_laid_off) * 100.0) / (SELECT SUM(total_laid_off) FROM layoffs_staging2) AS percentage_share
    FROM layoffs_staging2
    GROUP BY country
)
SELECT * FROM Country_Share
ORDER BY percentage_share DESC;

-- Automating Data Operations
-- Logging New Layoff Data 

CREATE TABLE layoffs_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    company TEXT,
    industry TEXT,
    country TEXT,
    total_laid_off INT,
    change_type VARCHAR(20),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_layoff_insert
AFTER INSERT ON layoffs_staging2
FOR EACH ROW
BEGIN
    INSERT INTO layoffs_log (company, industry, country, total_laid_off, change_type)
    VALUES (NEW.company, NEW.industry, NEW.country, NEW.total_laid_off, 'INSERTED');
END;

// 

DELIMITER ;

DELIMITER //

-- A procedure to predict future layoffs
CREATE PROCEDURE PredictLayoffs(IN growth_factor FLOAT)
BEGIN
    SELECT 
        industry, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_laid_off,
        ROUND(SUM(total_laid_off) * (1 + growth_factor), 2) AS predicted_next_year
    FROM layoffs_staging2
    GROUP BY industry, year
    ORDER BY year DESC;
END;

// 

DELIMITER ;
CALL PredictLayoffs(0.10);


-- Checking the functionality of trigger
INSERT INTO layoffs_staging2()
Values('Included Health','Toronto','Consumer',12,0.08,'2022-08-04','Series C','Canada',120);

SELECT *
FROM layoffs_log;
