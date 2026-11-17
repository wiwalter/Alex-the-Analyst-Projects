Select * from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data (data types)
-- 3. Null or blank values
-- 4. Remove Unnessary Columns (if any)
		-- never remove from the raw data set, use a staging table

-- Always begin by creating a staging table, to preserve the raw data.
CREATE TABLE layoffs_staging
Like Layoffs;
Insert layoffs_staging
Select * from layoffs;

-- CTE's functionally are just a more readable way to write subqueries. In this case, we are using the nesting to find duplicates by parition row_number() over all columns.

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

-- You cannot delete from a cte in MySQL per alex. I think this may actually be due to us using a window function.
 
 Select * 
 from layoffs_staging 
 where company = 'Casper';
 
 -- Creating a secondary staging table with data types.
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

-- Adding a row for row_num then using it to delete duplicates is the alternative method, because we cannot delete using the CTE.
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
 -- This is using select distincts on columns to find different rows that should actually by the same. Ex: Country: "United States" vs "United States."
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

-- One option is to find the information that should be in that null from elsewhere in our data. This may not always be possible.
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
