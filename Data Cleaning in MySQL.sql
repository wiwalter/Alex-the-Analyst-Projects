Select * from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data (data types)
-- 3. Null or blank values
-- 4. Remove Unnessary Columns (if any)
		-- never remove from the raw data set, use a staging table

CREATE TABLE layoffs_staging
Like Layoffs;
Insert layoffs_staging
Select * from layoffs;

with duplicate_cte AS
(
Select *,
 Row_number() over (
 Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
 from layoffs_staging
 )
 Select *
 from duplicate_cte
 Where row_num > 1;

-- Cannot delete from a cte in MySQL
 
 Select * 
 from layoffs_staging 
 where company = 'Casper';
 
 
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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 Insert into layoffs_staging2
 Select *,
 Row_number() over (
 Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
 from layoffs_staging;
 
Delete
 from layoffs_staging2 
 where row_num > 1;
 

 
 
 -- Standardizing Data
 -- Cleaning columns
 Select Distinct Industry
 from layoffs_staging2
 where industry like 'Crypto%';
 
 UPDATE layoffs_staging2
 Set company = trim(company);
 
UPDATE layoffs_staging2
Set industry = 'Crypto'
where industry like 'Crypto%';

Select *
from layoffs_staging2
where country = 'United States.'
order by 1;

Select Distinct country, trim(trailing '.' from country)
from layoffs_staging2
Order By 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like '%United States%';

-- Text to date
Select `date`, 
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
Modify column `date` DATE;

-- What do we do with nulls?

Select *
from layoffs_staging2
Where industry is null or industry = '';

 Select *
 from layoffs_staging2
 where company like '%Bally%';

 Select *
 from layoffs_staging2 t1
 Join layoffs_staging2 t2
	On t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null and t2.industry <> '';

Update layoffs_staging2 t1
 Join layoffs_staging2 t2
	On t1.company = t2.company
    and t1.location = t2.location
Set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null and t2.industry <> '';


-- Remove unused rows and columns
Delete
 from layoffs_staging2
 where total_laid_off is null 
 and percentage_laid_off is null;
 
 Alter Table layoffs_staging2
 Drop column row_num;
 
 Select *
 from layoffs_staging2;