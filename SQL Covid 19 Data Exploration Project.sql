/*

Covid 19 Data Exploration Project

*/

-- Testing table imports were successfull
SELECT *
FROM CovidDeaths
ORDER BY 3,4


SELECT *
FROM CovidVacc
ORDER BY 3,4


-- Looking at the data which we will be using in the Analysis
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at the Death Rate using Total Cases vs Total Death data in the U.K
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_rate%'
FROM CovidDeaths
WHERE Location = 'United Kingdom'
ORDER BY 1,2


-- Looking at the Death Rate using Total Cases vs Total Death data in the U.S.A
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_rate%'
FROM CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2


-- Looking at the Infection rate using Total Cases and Population
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS 'infection_%'
FROM CovidDeaths
WHERE Location = 'United Kingdom'
ORDER BY 1,2


-- Looking at Highest Infection Count vs Population of Countires
SELECT Location, Population, MAX(total_cases) as highest_infection, MAX(total_cases/population)*100 AS 'infection_%'
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY 'infection_%' DESC


-- Looking at Total Deaths per Country
-- Initial execute shows that datatype needs to be cast to Int from VarChar
-- Countries with Null Continent show as Location instead so remove from select
SELECT Location , MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC


-- Looking at Total Deaths per Continent
-- From earlier we know that when continent is null the location becomes the continent
SELECT Location, MAX(CONVERT(int, total_deaths)) as TotalDeaths
FROM CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY 2 DESC


-- Looking at Global Cases and Deaths
SELECT date, SUM(total_cases) as TotalCases, SUM(cast(total_deaths as int)) as TotalDeaths, SUM(cast(total_deaths as int))/SUM(total_cases)*100 as 'death_%'
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as TotalVaccinations
FROM CovidDeaths d
JOIN CovidVacc v
	ON d.Location = v.Location
	AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3


-- Looking at Vaccinations as a Percent of Total Populations
-- Using CTE of last Query to perform this action
WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as TotalVaccinations
FROM CovidDeaths d
JOIN CovidVacc v
	ON d.Location = v.Location
	AND d.date = v.date
WHERE d.continent is not null
)
SELECT *, (TotalVaccinations/population)*100 AS PercentVaccinated
FROM PopvsVac


-- Looking at Vaccinations as a Percent of Total Populations
-- Using Temp Tables of last Query to perform this action
DROP TABLE if exists #PopvsVac
CREATE TABLE #PopvsVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)
INSERT INTO #PopvsVac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as TotalVaccinations
FROM CovidDeaths d
JOIN CovidVacc v
	ON d.Location = v.Location
	AND d.date = v.date
WHERE d.continent is not null
SELECT *, (TotalVaccinations/population)*100 AS PercentVaccinated
FROM #PopvsVac


-- Creating a View to Store data for later visulizations
CREATE VIEW DeathsByContinent as
SELECT Location, MAX(CONVERT(int, total_deaths)) as TotalDeaths
FROM CovidDeaths
WHERE continent is null
GROUP BY Location

SELECT *
FROM DeathsByContinent
ORDER BY 2 DESC