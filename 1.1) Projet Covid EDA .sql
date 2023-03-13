SELECT TOP 1000 *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT TOP 1000 *
FROM ProjectPortfolio..CovidVaccinations
ORDER BY 3,4;

-- Select Data we're going to be using

SELECT	Location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths -- 

SELECT	Location,
		date,
		total_cases,
		total_deaths,
		(CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%france%'
ORDER BY 1,2;



-- At the end of 2022, in France, 0.4% of people who contracted covid died --

-- Here, I had to CAST the total_deaths and total_cases to do the division because of their data type (NVARCHAR). 
-- Therefore, I will convert the data I need in a more suitable format. 


ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN date DATE null
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN population FLOAT(53) NULL			
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_cases FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_cases FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_deaths FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_deaths FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_cases_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_cases_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_deaths_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_deaths_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN icu_patients FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN icu_patients_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN hosp_patients FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN hosp_patients_per_million FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_tests FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN total_tests_per_thousand FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_tests FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN new_tests_per_thousand FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidDeaths ALTER COLUMN positive_rate FLOAT(53) NULL



-- Let's see if we can do the calculations without using the CAST command: --
-- Total cases vs Total deaths for United Kingdom--

SELECT	Location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases)*100  as DeathPercentage

FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2;

-- In total, at the end of 2022, 0.88% of people who contracted covid in the UK died --



-- Looking at total cases vs Population --

-- What percentage of the population got Covid? --

SELECT	Location,
		date,
		total_cases,
		population,
		(total_cases/population)*100 as InfectionPercentage

FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%france%'
ORDER BY 1,2;

-- In France, on December 31, 2022, 58% of the population had contracted covid since the start of the pandemic.

-- In fact, the InfectionPercentage variable is not exactly what it seems to be. Some people got covid multiple times and some people are not permanent resident in this country.
-- However, this variable seems to be a good proxy for the real infection rate. We will use it for the rest of the analysis. 


-- What countries have the highest Infection rate?

SELECT	Location,
		MAX(total_cases) as HighestInfectionCount ,
		population,
		(MAX(total_cases)/population)*100 as InfectionPercentage
FROM ProjectPortfolio..CovidDeaths
GROUP BY	Location,
			population
ORDER BY InfectionPercentage DESC;

-- Logically, small countries are overrepresented in this ranking, since it's easier for the virus to spread there. --
-- Cyprus is first with an infection rate over 70% --

-- Let's check for countries with a population over 10 million --

SELECT	Location,
		continent,
		MAX(total_cases) as HighestInfectionCount ,
		population,
		(MAX(total_cases)/population)*100 as InfectionPercentage

FROM ProjectPortfolio..CovidDeaths
WHERE population > 10000000 AND continent IS NOT NULL
GROUP BY	Location,
			continent,
			population
ORDER BY InfectionPercentage DESC;

-- France is the country with the highest infection rate. One key parameter is the tourism. Before the pandemic, France was walcoming more than 80 millions tourists per year). --
-- We notice that Europe seems to have been more affected by covid than other continents --

-- Let's check the numbers per continent -- 

SELECT	location,
		MAX(total_cases) as HighestInfectionCount ,
		population,
		(MAX(total_cases)/population)*100 as InfectionPercentage

FROM ProjectPortfolio..CovidDeaths
WHERE	continent IS  NULL
		AND location IN ('Europe','Oceania','North America','South America', 'Asia','Africa') 
GROUP BY	location,
			population
ORDER BY InfectionPercentage DESC;

-- Europe is the continent most affected by covid (in terms of Infection Rate). We can see the key role of globalization in the spread of the virus.
-- Africa, which is the continent that receives the fewest people, is the continent least affected by the virus.


-- Showing countries with Highest Death Count per Population --

SELECT	Location,
		MAX(total_deaths) as TotalDeathCount ,
		population,
		(MAX(total_deaths)/population)*100 as DeathPercentage

FROM ProjectPortfolio..CovidDeaths
GROUP BY	Location,
			population
ORDER BY DeathPercentage DESC;

-- Just like the Infection Rate, the Death Rate is higher in small countries.


-- Showing countries with absolute Highest Death Count  --

SELECT	Location,
		MAX(total_deaths) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;
 
-- Logically, hte largest and most globalized countries have been more affected by the virus in absolute.

-- Let's break things by continent --

SELECT	continent,
		MAX(total_deaths) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- It doesn't seem to be the right numbers (USA = North America ??), let's try another way --

SELECT	location,
		MAX(total_deaths) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS  NULL AND  location IN ('Europe','Oceania','North America','South America', 'Asia','Africa') 
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Here, the results seem coherent --
-- Europe is the most affected continent. But these numbers maybe not be accurate considering the suspicions on the Chinese numbers. --
-- This ranking may also change in the next months with the explosion of the number of cases in China following the end of the restrictions in the whole country. --



--- GLOBAL NUMBERS ---

-- BY DATE --
SELECT	date,
		SUM(new_cases) as new_cases_today,
		SUM(new_deaths) as new_deaths_today,
		(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage_today
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- FULL PERIOD --

SELECT	-- date,
		SUM(new_cases) as total_cases,
		SUM(new_deaths) as total_deaths,
		(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;




-- Now, let's work on the vaccinations --

SELECT *
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
ORDER BY death.location, death.date

-- We can join the tables but we have to convert the data from the 'Vaccinations' table to do calculations later on. --
-- At first, I wanted to convert some variables in the 'BIGINT' format but it makes impossible the calculations. I will therefore convert the data I may use in 'Float', exactly like for the first table. --

ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN date DATE null
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN total_vaccinations FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN people_vaccinated FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN people_fully_vaccinated FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN tests_per_case FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN total_boosters FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN new_vaccinations FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN median_age FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN aged_65_older FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN aged_70_older FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN gdp_per_capita FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN extreme_poverty FLOAT(53) NULL
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN cardiovasc_death_rate FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN diabetes_prevalence FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN female_smokers FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN male_smokers FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN hospital_beds_per_thousand FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN life_expectancy FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN human_development_index FLOAT(53) NULL	
ALTER TABLE ProjectPortfolio..CovidVaccinations ALTER COLUMN excess_mortality FLOAT(53) NULL	



-- Looking at the evolution 'Vaccinations vs Population'--
SELECT	death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as BIGINT)) 
			OVER (Partition by death.location ORDER BY death.location, death.date) as people_vaccinated
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3;

-- Let's check the percentage of the population vaccinated --
-- Method 1:CTE -- 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
	SELECT	death.continent,
		death.location,
		CONVERT(varchar, death.date, 23) as date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as BIGINT)) 
			OVER (Partition by death.location ORDER BY death.location, death.date) as people_vaccinated

	FROM ProjectPortfolio..CovidDeaths death
	JOIN ProjectPortfolio..CovidVaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
	-- ORDER BY 2,3
	)
SELECT	*,
		(RollingPeopleVaccinated / Population)*100 AS Percentage_Vaccination
FROM PopvsVac




-- Method 2: TEMP TABLE --

DROP TABLE IF EXISTS #PercentagePopVaccinated
CREATE TABLE #PercentagePopVaccinated
(
	Continent NVARCHAR(225),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopVaccinated
SELECT	death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as BIGINT)) 
			OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

	FROM ProjectPortfolio..CovidDeaths death
	JOIN ProjectPortfolio..CovidVaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
	-- ORDER BY 2,3

SELECT	*,
		(RollingPeopleVaccinated / Population)*100 AS Percentage_Vaccination
FROM #PercentagePopVaccinated




-- Creating view to store data for later visualizations --

CREATE VIEW  PercentPopVaccinated AS
SELECT	death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as BIGINT)) 
			OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

	FROM ProjectPortfolio..CovidDeaths death
	JOIN ProjectPortfolio..CovidVaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
