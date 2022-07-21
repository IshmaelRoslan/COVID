/*
Query for Global Figures over Time
*/
SELECT CONVERT(DATE,cas.date) AS date, total_deaths_per_million,  total_cases_per_million, pop.people_fully_vaccinated_per_hundred, cas.location
FROM CovidProject..CovidDeaths cas JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location AND cas.date = pop.date
--WHERE cas.location = 'World'
ORDER BY location DESC

/*
Query for Map showing % Vaccination Rate over Time per Country
*/

SELECT cas.date, cas.location, pop.people_fully_vaccinated_per_hundred
FROM CovidProject..CovidDeaths cas JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location AND cas.date = pop.date
WHERE cas.continent IS NOT NULL
ORDER by 1 DESC

/*
Query for Graph showing New Deaths vs Vaccination % by location over time.
*/

SELECT CONVERT(DATE,cas.date) AS date, cas.location, new_deaths_smoothed_per_million, pop.people_fully_vaccinated_per_hundred
FROM CovidProject..CovidDeaths cas JOIN CovidProject..CovidVaccinations pop ON cas.location = pop.location AND cas.date = pop.date
WHERE cas.continent IS NOT NULL
ORDER by 1 DESC
