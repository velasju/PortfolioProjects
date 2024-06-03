select *
from CovidDeaths
where continent is not Null
order by 3, 4


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not Null
order by 1, 2


--Looking at total cases vs total deaths
--Shows likelyhood of dying if covid is contracted in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not Null
order by 1, 2

--Looking at total case vs population
--Shows what percentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as PercentInfections
from PortfolioProject..CovidDeaths
where continent is not Null
--where location like '%states%'
order by 1, 2

--Countries with hightest infections compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfections
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
group by Location, population
order by PercentPopulationInfections desc


--Breakdown by Continent (This query is giving the correct numbers)
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is Null
group by location
order by TotalDeathCount desc


--Breakdown by Continent (This query is giving the questinable numbers)
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not Null
group by continent
order by TotalDeathCount desc


--Shows continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not Null
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not Null
--group by date
order by 1, 2


--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.Location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..Vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use Cte
with PopvsVac (continent, Lacation, date, population, new_vaccinations,rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.Location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..Vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.Location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..Vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store date for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.Location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..Vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

