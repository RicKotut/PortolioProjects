Select*
From PortfolioProject..CovidDeaths
Order By 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
Where continent is not null
Order By 1,2

--Looking at the Total Cases vs Population

Select location, date, total_cases, population, (total_cases/NULLIF(population, 0))*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
Where continent is not null
Order By 1,2

--Looking at countries with highest Infection rates compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/NULLIF(population, 0))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group By location, population
Order By PercentagePopulationInfected desc

--Looking at countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group By location
Order By TotalDeathCount desc


--LET'S BREAK THINGS BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--Showing the continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--GLOBAL NUMBERS

Select Sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/NULLIF(sum(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group By date
Order By 1,2


--Looking at Total Population vs Total Vaccination
---Use CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as BIGINT)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
--Order By 2,3
)

Select*, (RollingPeopleVaccinated/population)*100 
From PopvsVac


---Alternatively Use TEMP TABLE

----DROP TABLE if exist #PercentPopulationVaccinated (If you need to alter anything within the Temp Table)
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar (255),
date datetime, 
population numeric, 
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as BIGINT)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
--Order By 2,3

Select*, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


--Creating View to store Data for later visualizatio
CREATE VIEW PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as BIGINT)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
--Order By 2,3

Select*
From PercentPopulationVaccinated