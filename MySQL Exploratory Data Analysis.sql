-- Exploratory Data Analysis
-- Relies on the cleaned data from the previous exercise.
Select *
From layoffs_staging2;

-- Look at max for total people laid off
Select Max(total_laid_off), Max(percentage_laid_off)
From layoffs_staging2;

-- Look at companies that lost all employees in a layoff
Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by total_laid_off DESC;

Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions DESC;

-- Group by company. Added count, as it was something alex was questioning
select company, sum(total_laid_off), count(total_laid_off), count(*)
from layoffs_staging2
Group by company
order by 2 desc;

-- Find date range
Select min(`date`), max(`date`)
from layoffs_staging2;

-- Group by industry
Select industry, sum(total_laid_off)
from layoffs_staging2
Group by industry
order by 2 DESC;

-- Group by country, count added as these are just reported layoffs
Select country, sum(total_laid_off), count(total_laid_off)
from layoffs_staging2
Group by country
order by 2 DESC;

-- Group by year
Select Year(`date`), sum(total_laid_off), count(total_laid_off)
from layoffs_staging2
Group by Year(`date`)
order by 1 DESC;


-- Group by company stage - seed -> series A-J -> Post-IPO or Acquired. Added a round to avg percentage_laid_off for readability.
Select stage, sum(total_laid_off), count(total_laid_off), Round(Avg(percentage_laid_off), 2)
from layoffs_staging2
Group by stage
order by 2 DESC;

-- Average percent laid off by company
Select company, Round(Avg(percentage_laid_off), 2)
from layoffs_staging2
Group by company
order by 2 DESC;


-- Rolling total of layoffs by month
Select substring(`date`, 1, 7) as `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
Where `date` is not null
Group by `MONTH`
Order by 1 ASC;

WITH Rolling_Total As
(
Select substring(`date`, 1, 7) as `MONTH`, sum(total_laid_off) AS total_off
FROM layoffs_staging2
Where `date` is not null
Group by `MONTH`
Order by 1 ASC
)
Select `MONTH`, total_off, sum(total_off) OVER (ORDER by `MONTH`) as rolling_total
from Rolling_total;

-- Adding count for fun
WITH Rolling_Total As
(
Select substring(`date`, 1, 7) as `MONTH`, sum(total_laid_off) AS total_off, count(total_laid_off) as count_total_off
FROM layoffs_staging2
Where `date` is not null
Group by `MONTH`
Order by 1 ASC
)
Select `MONTH`, total_off, sum(total_off) OVER (ORDER by `MONTH`) as rolling_total, sum(count_total_off) OVER (ORDER by `MONTH`) as rolling_count
from Rolling_total;

-- Total layoffs by comany by year
Select company, YEAR(`date`), Sum(total_laid_off)
from layoffs_staging2
Group by company, YEAR(`date`)
Order by 3 DESC;

-- Find top layoffs by company for each year. Shows another way to do aliases in a cte. Use DENSE RANK() to not skip when there are ties in rank. Shows how to use multiple CTEs in a query.
With Company_Year (company, years, total_laid_off) as
(Select company, YEAR(`date`), Sum(total_laid_off)
from layoffs_staging2
Group by company, YEAR(`date`)
), Company_Year_Rank AS
(Select *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as ranking
 from Company_year
 WHERE years is not null)
 Select * from Company_Year_Rank
 Where Ranking <= 5;

Select *
From layoffs_staging2;