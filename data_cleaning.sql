-- Data Cleaning
Use world_layoffs;

SELECT *
FROM layoffs;

-- Creating a dummy table to avoid interfering with the base table
CREATE TABLE layoffs_staging
LIKE  layoffs;

DESC layoffs_staging; -- structure

-- copying the values from base table
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Remove duplicates

-- Creating a CTE to check in if there are duplicate columns
WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
Where row_num>1;

-- We cannot directly delete values from the table using a CTE in mysql so first let's check where the duplicate values reside and see if we can do something

SELECT *
FROM layoffs_staging
WHERE company='Casper';

-- Creating a dummy table again to delete those values
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;
INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num>1;

SELECT *
FROM layoffs_staging2;

-- successfully the duplicates are removed



-- Standardize the Data

-- removing unnessary spacing
SELECT  Distinct company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company= TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- We can see that crypto industry is taking space as three distinct values so updating all those to a common one i.e crypto

UPDATE layoffs_staging2
SET industry ='Crypto'
Where industry LIKE 'Crypto%';


SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- We can see that someone has put 'United Status.' instead of United Status, so updating with the changes

UPDATE layoffs_staging2
SET country=TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT `date`
FROM layoffs_staging2;

-- Altering date table discrepancies
UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%YYYY');

ALTER TABLE layoffs_staging2
MODIFY column `date` DATE;

-- Null values or blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry='';

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry='';

SELECT * 
FROM layoffs_staging2
WHERE company='Airbnb';

SELECT t1.industry,t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company=t2.company 
    AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company=t2.company 
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- Remove Any columns

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;          -- finalized table after data cleaning


