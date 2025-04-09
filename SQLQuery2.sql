SELECT* 
FROM portfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT* 
--FROM portfolioProject..CovidVaccinations$
--ORDER BY 3,4

--- select data we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--looking at total cases vs total deaths
--shows the chance of you dying if you contract covid in xcountry
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM portfolioProject..CovidDeaths$
WHERE location LIKE '%France%'
AND continent is not null
ORDER BY 1,2

-- looking at the total cases vs population
-- show what percentage of populaton got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as GotCovidPercentage
FROM portfolioProject..CovidDeaths$
WHERE location LIKE '%France%'
ORDER BY 1,2

-- looking at countries with the highest infestion rate compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount, population,MAX((total_cases/population))*100 as GotCovidPercentage
FROM portfolioProject..CovidDeaths$
--WHERE location LIKE '%France%'
GROUP BY location,population
ORDER BY GotCovidPercentage desc 

-- showing the countries with the highest deaths count per population
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathsCount
FROM portfolioProject..CovidDeaths$
--WHERE location LIKE '%France%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc 



-- Global numbers
 SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
FROM portfolioProject..CovidDeaths$
--WHERE location LIKE '%France%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

WITH PopvsVac (continent,location,date, population,new_vaccinnations, RollingPeopleVaccinated)
as

(
-- looking ar total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths$ dea
JOIN portfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)/100
FROM PopvsVac

--Time table
DROP TABLE IF  exists #percentagePopulationVaccinated
CREATE TABLE #percentagePopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #percentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths$ dea
JOIN portfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #percentagePopulationVaccinated

-- creating view to store data for later visualizations
CREATE VIEW percentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths$ dea
JOIN portfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--SELECT * 
--FROM sys.views 
--WHERE name= 'percentagePopulationVaccinated';

SELECT* 
FROM percentagePopulationVaccinated;