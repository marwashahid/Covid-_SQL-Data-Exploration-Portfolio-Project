SELECT * FROM
SQLDataExploration..Deaths
WHERE continent is not null
order by 3,4


--SELECT data that we are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM SQLDataExploration..Deaths order by 1,2


--Looking at total cases vs total deaths

--Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM SQLDataExploration..Deaths
where location like '%states%' and continent is not null
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location,total_cases,population, (total_cases/population)*100 as covid_percentage
FROM SQLDataExploration..Deaths
--where location like '%states%'
order by 1,2

--Looking at countries with the the highest infection rate
SELECT location,MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as highestInfectedpercentage
FROM SQLDataExploration..Deaths
--where location like '%states%'
GROUP BY location,population
order by highestInfectedpercentage desc

--Showing countries with the highest death Count per population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..Deaths
where continent is not null
GROUP BY location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY continent

--SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM SQLDataExploration..Deaths
--where continent is null
--GROUP BY location
--order by TotalDeathCount desc


--Showing continents with the highest death count

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..Deaths
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--GLOBAL numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM SQLDataExploration..Deaths
--where location like '%states%'
where continent is not null
--GROUP BY  date
order by 1,2


-- Looking at total population vs vaccinations

SELECT dea.continent,dea.location, dea.date,dea.population, vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated FROM
SQLDataExploration..Deaths dea JOIN
SQLDataExploration..Vaccinations vacc ON
dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVacc (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(SELECT dea.continent,dea.location, dea.date,dea.population, vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated FROM
SQLDataExploration..Deaths dea JOIN
SQLDataExploration..Vaccinations vacc ON
dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as vaccinatedPercentage
FROM PopvsVacc




--TEMP table

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent,dea.location, dea.date,dea.population, vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated FROM
SQLDataExploration..Deaths dea JOIN
SQLDataExploration..Vaccinations vacc ON
dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as vaccinatedPercentage
FROM #PercentPeopleVaccinated

--Creating VIEW to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated
as
SELECT dea.continent,dea.location, dea.date,dea.population, vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated FROM
SQLDataExploration..Deaths dea JOIN
SQLDataExploration..Vaccinations vacc ON
dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPeopleVaccinated