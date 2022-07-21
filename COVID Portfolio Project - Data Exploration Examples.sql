--- Inital Exploration of Cases and Deaths
SELECT 
  * 
FROM CovidProject..CovidDeaths
ORDER BY 
  1, 
  4 

SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population 
FROM 
  CovidProject..CovidDeaths
ORDER BY 
  1, 
  4
  
 -- Looking at Total Cases vs Total Deaths
 -- Likelihood of dying from COVID-19 if you test positive.

SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (100 * total_deaths / total_cases) AS death_rate 
FROM 
  CovidProject..CovidDeaths
WHERE 
  location = 'United Kingdom' 
ORDER BY 
  1, 
  2
  
  -- Looking at Total Cases vs Population
SELECT 
  location, 
  date, 
  total_cases, 
  population, 
  (total_cases / population)* 100 AS cases_per_population 
FROM 
  CovidProject..CovidDeaths
WHERE 
  location = 'United Kingdom' 
ORDER BY 
  1, 
  2
  
  -- Looking at Countries with Highest Death Rate per Population
  -- total_deaths appears to have an incorrect data_type : nvarchar(255)

SELECT 
  location, 
  population, 
  MAX(
    CAST(total_deaths AS INT)
  ) AS HighestDeathCount, 
  MAX(
    CAST(total_deaths AS INT)
  )/ population * 100 AS PercentPopulationDeaths 
FROM 
  CovidProject..CovidDeaths
WHERE 
  continent IS NOT NULL -- There are some locations which are aggregates, and not countries.
GROUP BY 
  location, 
  population 
ORDER BY 
  PercentPopulationDeaths DESC
  
  -- Looking at Continent with Highest Death Rate per Population
  -- total_deaths appears to have an incorrect data_type : nvarchar(255)

SELECT 
  continent, 
  SUM(
    CAST(total_deaths AS INT)
  ) AS DeathCount, 
  SUM(
    CAST(total_deaths AS INT)
  )/ SUM(population) * 100 AS DeathRate 
FROM 
  CovidProject..CovidDeaths
WHERE 
  continent IS NOT NULL -- There are some locations which are aggregates, and not countries.
GROUP BY 
  continent 
ORDER BY 
  3 DESC
  
-- Global Numbers to Date
SELECT 
  SUM(new_cases) AS total_cases, 
  SUM(
    CAST(new_deaths AS INT)
  ) AS total_deaths, 
  SUM(
    CAST(new_deaths AS INT)
  )/ SUM(new_cases) * 100 AS DeathRatePercent 
FROM 
  CovidProject..CovidDeaths
WHERE 
  continent IS NOT NULL
  
-- There are some locations which are aggregates, and not countries.
-- Data about Tests and Vaccinations

SELECT 
  * 
FROM 
  CovidProject..CovidVaccinations 
ORDER BY 
  1, 
  4
  
--Demonstrating Joins
SELECT 
  cas.continent, 
  cas.location, 
  cas.date, 
  cas.population, 
  pop.new_vaccinations 
FROM 
  CovidProject..CovidDeaths cas
  JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location 
  AND cas.date = pop.date 
ORDER BY 
  2, 
  3

-- Demonstrating PARTITION BY and Common Table Expressions to perform calculations on that query
--  Vaccinations per Population
WITH PopvsVac AS (
  SELECT 
    cas.continent, 
    cas.location, 
    cas.date, 
    cas.population, 
    pop.new_vaccinations, 
    SUM(
      CONVERT(BIGINT, pop.new_vaccinations)
    ) OVER (
      PARTITION BY cas.location 
      ORDER BY 
        cas.location, 
        cas.date
    ) AS RollingVaccinations 
  FROM 
    CovidProject..CovidDeaths cas 
    JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location 
    AND cas.date = pop.date 
  WHERE 
    cas.continent IS NOT NULL
) 
SELECT 
  *, 
  (RollingVaccinations / population)* 100 AS VaccinationRate 
FROM 
  PopvsVac

  
-- As Above but using TEMP TABLES
-- Using Temp Table to perform Calculation on Partition By in previous query
DROP 
  TABLE IF exists #PercentPopulationVaccinated
  CREATE TABLE #PercentPopulationVaccinated
  (
    Continent nvarchar(255), 
    Location nvarchar(255), 
    Date datetime, 
    Population numeric, 
    New_Vaccinations numeric, 
    RollingVaccinations numeric
  ) INSERT INTO #PercentPopulationVaccinated
SELECT 
  cas.continent, 
  cas.location, 
  cas.date, 
  cas.population, 
  pop.new_vaccinations, 
  SUM(
    CONVERT(INT, pop.new_vaccinations)
  ) OVER (
    Partition by cas.Location 
    Order by 
      cas.location, 
      cas.Date
  ) as RollingVaccinations 
FROM 
  CovidProject..CovidDeaths cas 
  JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location 
  AND cas.date = pop.date 

Select 
  *, 
  (RollingVaccinations / Population)* 100 
From 
  #PercentPopulationVaccinated


-- Creating Views to store for later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
  cas.continent, 
  cas.location, 
  cas.date, 
  cas.population, 
  pop.new_vaccinations, 
  SUM(
    CONVERT(INT, pop.new_vaccinations)
  ) OVER (
    PARTITION BY cas.Location 
    ORDER BY
      cas.location, 
      cas.Date
  ) AS RollingPeopleVaccinated
FROM
  CovidProject..CovidDeaths cas 
  JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location 
  AND cas.date = pop.date 
WHERE
  cas.continent IS NOT NULL
