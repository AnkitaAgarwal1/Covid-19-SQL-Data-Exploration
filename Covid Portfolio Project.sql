Select *
From project.dbo.CovidDeaths
Where continent IS NOT NULL
Order by location, date

--Select *
--From project.dbo.CovidVaccinations
--Order by location, date

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From project.dbo.CovidDeaths
Order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- shows likelihhod of dying if you contract in your country

Select location, date, total_cases, CAST(total_deaths as numeric) AS TotalDeaths, (CAST(total_deaths as numeric)/total_cases)*100 AS DeathPercentage
From project.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From Project.dbo.CovidDeaths
Where total_cases  IS Not NULL 
--location like '%states%'
Order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
From project.dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From project.dbo.CovidDeaths
--Where location like '%states%'
Where continent IS NOT NULL
Group by location
Order by TotalDeathCount desc


--Lets's break things down by Continent


--Showing Continents with the highest death count per population

Select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From project.dbo.CovidDeaths
--Where location like '%states%'
Where continent IS NOT NULL
Group by continent
Order by TotalDeathCount desc




-- GLOBAL NUMBER


Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
From Project.dbo.CovidDeaths
--Where location like '%states%'
Where continent IS NOT NULL
--Group by date
Order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,Vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
From Project.dbo.CovidDeaths  dea
JOIN Project.dbo.CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,Vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
From Project.dbo.CovidDeaths  dea
JOIN Project.dbo.CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From  PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,Vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
From Project.dbo.CovidDeaths  dea
JOIN Project.dbo.CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated




---Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,Vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
From Project.dbo.CovidDeaths  dea
JOIN Project.dbo.CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3

Select *
From PercentPopulationVaccinated
