
Select * 
From PortfolioProject..CovidDeaths$
Order by 3, 4

---Select * 
---From PortfolioProject..CovidVaccinations$
---Order by 3, 4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1, 2

---Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Zambia%'
Order by 1, 2

---Looking at Total Cases vs Population
--Shows what percentage of the popuation contracted covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%Zambia%'
Order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%Zambia%'
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location,  Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Zambia%'
Where continent is NOt NULL
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent,  Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Zambia%'
Where continent is NOT NULL
Group by continent
Order by TotalDeathCount desc


--Showing Continents with Highest Death Count

Select continent,  Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Zambia%'
Where continent is NOT NULL
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Zambia%'
Where continent is NOT NULL
--Group by Date
Order by 1, 2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
		and dea.date=vac.date
Where dea.continent is NOT NULL
Order by 2, 3





--USE Common Table Expression
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
		and dea.date=vac.date
Where dea.continent is NOT NULL
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
		and dea.date=vac.date
Where dea.continent is NOT NULL
--Order by 2, 3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVacinated


--Create a View to store  data for later visualizations
Create View PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
		and dea.date=vac.date
Where dea.continent is NOT NULL
--Order by 2, 3

Select *
From PercentPopulationVacinated