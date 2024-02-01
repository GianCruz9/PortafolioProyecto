
USE PROYECTO_PORTAFOLIO

SELECT * 
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM PROYECTO_PORTAFOLIO..['CovidVaccinations]
ORDER BY 3,4

-- SELECT DATA THAR WE ARE GOING TO GE USING

SELECT location,date,total_cases, new_cases, total_deaths, population
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
ORDER BY 1,2

-- LOOKING AT TOTAL CASE VS TOTAL DEATHS
-- SHOW LIKEHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float)) * 100 as DeathPercentage
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE location like '%Peru%' and
continent is not null
ORDER BY 1,2 DESC


-- LOOKING AT TOTAL CASE VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID


SELECT location, date, population ,total_cases, (total_cases/population) * 100 as Population_Percentage
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as Population_Percentage
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
GROUP BY location,population
ORDER BY Population_Percentage desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER PORPULATION

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINET

-- showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(new_deaths)  / SUM(new_cases) * 100 AS DeathPercentage
FROM PROYECTO_PORTAFOLIO..['CovidDeaths']
WHERE continent is not null	
--GROUP BY date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS


SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location,
	CD.date) AS RollingPeopleVaccinated
,	(RollingPeopleVaccinated/population)*100 as
FROM PROYECTO_PORTAFOLIO..['CovidDeaths'] AS CD
JOIN PROYECTO_PORTAFOLIO..['CovidVaccinations] AS CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent is not null and cd.population is not null
ORDER BY 2,3

-- USE CTE

WITH PobvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location,
	CD.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 as
FROM PROYECTO_PORTAFOLIO..['CovidDeaths'] AS CD
JOIN PROYECTO_PORTAFOLIO..['CovidVaccinations] AS CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent is not null and cd.population is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PobvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #TempPercentPopulationInated
CREATE TABLE #TempPercentPopulationInated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #TempPercentPopulationInated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location,
	CD.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 as
FROM PROYECTO_PORTAFOLIO..['CovidDeaths'] AS CD
JOIN PROYECTO_PORTAFOLIO..['CovidVaccinations] AS CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent is not null and cd.population is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #TempPercentPopulationInated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated 
as
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location,
	CD.date) AS RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 as
FROM PROYECTO_PORTAFOLIO..['CovidDeaths'] AS CD
JOIN PROYECTO_PORTAFOLIO..['CovidVaccinations] AS CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent is not null and cd.population is not null
--ORDER BY 2,3