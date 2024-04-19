Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4



--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if your contract covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

----Looking at Total cases vs Population
--Shows What percentage of Population got Covid


Select Location, date,population, total_cases,(total_cases/population)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population


Select Location,population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By Location, Population
order by PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count per Population

	Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group By Location
	order by TotalDeathCount desc

	-- Lets Break it Down By Continent

	Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group By continent
	order by TotalDeathCount desc

	-- Showing Continents with the Highest death count per population

	Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group By continent
	order by TotalDeathCount desc


--Global Numbers

 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date 
order by 1,2

--Looking At Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not Null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not Null
	--order by 2,3
)	
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New Vaccinations numeric,
RollingPeopleVaccinated numeric

Insert into #PercentPopulatedVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not Null
	--order by 2,3
Select *, (#PercentPopulatedVaccinated/Population)*100
From #PercentPopulatedVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not Null
	--order by 2,3

Select *
From PercentPopulationVaccinated
