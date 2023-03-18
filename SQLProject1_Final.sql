/*

PROJECT 1: COVID DATA EXPLORATION

*/

SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--SELECT DATA FROM TABLES
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--COMPARE TOTAL CASES TO TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--TOTAL CASES TO POPULATION
SELECT location, date, population, total_cases, (total_cases/population)*100 as infection_rate
FROM PortfolioProject1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--HIGHEST INFECTION RATE TO POPULATION
SELECT location, population, MAX(total_cases) as max_infected_population, (MAX(total_cases)/population)*100 as infection_rate
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY 4 desc

--HIGHEST DEATH COUNT
SELECT location, MAX(total_deaths) as total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--HIGHEST DEATH COUNT BY CONTINENT
SELECT location, MAX(total_deaths) as total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent is  null
GROUP BY location
ORDER BY total_death_count desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--TOTAL POPULATION VS VACCINATION
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM PortfolioProject1..CovidDeaths d
JOIN PortfolioProject1..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
ORDER BY 1,2,3

--ROLLING COUNT OF VACCINATIONS
--Created a CTE to use a newly created column for calculations
WITH popvac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_vaccinations
FROM PortfolioProject1..CovidDeaths d
JOIN PortfolioProject1..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
)
SELECT *, (rolling_vaccinations/population)*100 as rolling_vax_percentage
FROM popvac

--Same results but with temp table instead of CTE
DROP TABLE IF EXISTS #popvac
CREATE TABLE #popvac
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #popvac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_vaccinations
FROM PortfolioProject1..CovidDeaths d
JOIN PortfolioProject1..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null

SELECT *, (rolling_vaccinations/population)*100 as rolling_vax_percentage
FROM #popvac

--CREATING VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_vaccinations
FROM PortfolioProject1..CovidDeaths d
JOIN PortfolioProject1..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
