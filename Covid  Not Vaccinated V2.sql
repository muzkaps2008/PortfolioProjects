Select * 
From [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
Order By 3,4



--Select * 
--From [Portfolio Project]..CovidVaccinations
--Order By 3,4


--Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
Order By 1,2


--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as TotaldeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%zambia%'
Order By 1,2


--Looking at Total cases vs Population
-- Shows what percentage of the population contracted Covid


Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location like '%zambia%'
Order By 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%zambia%'
where continent IS NOT NULL
Group by location, population
Order By PercentPopulationInfected desc



-- Showing Countries with the Highest Death Count per Population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%zambia%'
where continent IS NOT NULL
Group by location
Order By TotalDeathCount desc


--Lets break things down by continent

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%zambia%'
where continent IS NULL
Group by location
Order By TotalDeathCount desc


--Showing the continents with the highest deaths per population
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%zambia%'
where continent IS NOT NULL
Group by continent
Order By TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotaldeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%zambia%'
Where continent IS NOT NULL
--Group by date
Order By 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
 --  , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE (Common Table Expression)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
 --  , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentagepopulationVaccinated
Create Table #PercentagepopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagepopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
 --  , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagepopulationVaccinated



--Creating View to store data for later visualizations


Create View PercentagepopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
 --  , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagepopulationVaccinated