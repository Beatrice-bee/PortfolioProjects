SELECT *
FROM PortfolioProject.dbo.covidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.covidVaccinations
--ORDER BY 3,4

--Selecting data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.covidDeaths
ORDER BY 1,2

--looking at total_cases vs total_deaths
--likelihood of death in africa

SET ARITHABORT OFF   -- Default 
SET ANSI_WARNINGS OFF
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.covidDeaths
WHERE location like '%africa%'
ORDER BY 1,2

--looking at total cases vs population
--showing waht % of population has covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.covidDeaths
WHERE location like '%africa%'
ORDER BY 1,2

--looking at countries with the hhighest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.covidDeaths
--WHERE location like '%africa%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

--showing countries with highest death count on population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.covidDeaths
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- BREAKDOWN BY CONTINENT


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.covidDeaths
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- global numbers
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.covidDeaths
--WHERE location like '%africa%'
WHERE continent is not null
ORDER BY 1, 2

-- total poppulation vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY  2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY  2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--WHERE dea.continent is not null
--ORDER BY  2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated


--CREATE VIEW FOR LATER VISUALIZATION

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY  2, 3

Select *
From PercentPopulationVaccinated


