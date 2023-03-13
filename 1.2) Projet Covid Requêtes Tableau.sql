/* Queries used for the Tableau part of the project */

-- 1: Death percentage among the people infected in the world --

SELECT 
		SUM(CAST(new_cases AS BIGINT)) as Total_cases,
		SUM(CAST(new_deaths AS BIGINT)) as Total_deaths,
		(SUM(CAST(new_deaths AS FLOAT)))/(SUM(CAST(new_cases AS FLOAT)))*100 AS Death_percentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- 2: Number of deaths by continent --


SELECT	location,
		SUM(CAST(new_deaths AS INT)) AS Total_deaths_count
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL AND LOCATION IN ('North America', 'South America', 'Europe', 'Africa', 'Asia', 'Oceania')
GROUP BY location
ORDER BY Total_deaths_count DESC;


-- 3: Percentage of the population infected by country --

SELECT	location,
		population,
		MAX(total_cases) AS Highest_infection_count,
((MAX(total_cases))/population)*100 AS Percent_pop_infected
FROM ProjectPortfolio..CovidDeaths
GROUP BY location, population
ORDER BY Percent_pop_infected DESC


-- 4: 

SELECT	location,
		population,
		date,
		MAX(total_cases) AS Highest_infection_count,
		((MAX(total_cases))/population)*100 AS Percent_pop_infected
FROM ProjectPortfolio..CovidDeaths
GROUP BY location, date, population
ORDER BY Percent_pop_infected DESC



            
