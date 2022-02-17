select *
from PortfolioProject..CovidDeaths$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows the Likelihood of dying if you contract Covid in Ghana

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like 'ghana'
order by 1,2


--Looking at the Total cases vs Population
select location, date, population, total_cases,  (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
Where location like 'ghana'
order by 1,2

select location, date, population, total_cases,  (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths$
group by location, population
order by PopulationInfectedPercentage desc


--Showing countries with the highest Death count per Poplulation
select location, population, MAX(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by TotaldeathCount desc

-- BREAKING INTO CONTINENT
select location, MAX(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotaldeathCount desc

--Global Numbers 

select  date, Sum(new_cases) as total_new_cases,  sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


--looking at Total Population vs Vaccination
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location , Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100 as Percentage
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated


