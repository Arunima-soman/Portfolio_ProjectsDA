select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--select Location, date, total_cases, total_deaths,( total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
--order by 1,2

select Location, date, total_cases, population,( total_cases/population)*100 as CovidPercentage
from PortfolioProject.dbo.CovidDeaths
where Location like '%India%'
order by 1,2

--countries with highest infection rate

select Location, population, MAX( total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
group by location, population
order by PercentPopulationInfected desc

--countries with highest death count per population

select Location, MAX( total_deaths) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
Where continent is not null
group by location, population
order by TotalDeathCount desc

--lets break things down by continent

select location, MAX( total_deaths) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
Where continent is null
group by location
order by TotalDeathCount desc

select continent, MAX( total_deaths) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
Where continent is not null
group by continent
order by TotalDeathCount desc


--continents with highest death count per population

select continent, MAX( total_deaths) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers

select sum(New_cases) as total_cases, sum(cast(New_deaths as int)) as total_deaths, sum(cast(New_deaths as int))/ sum(New_cases)*100 As DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
where continent is not null
--group by date
order by 1,2

select *
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date


--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 1,2,3

--use CTE

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    ,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
    as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--creating view for data for later visualization

--select Location, population, MAX( total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--from PortfolioProject.dbo.CovidDeaths
----where Location like '%India%'
--group by location, population
--order by PercentPopulationInfected desc


Create view PercentPopulationInfected as
select Location, population, MAX( total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where Location like '%India%'
group by location, population
--order by PercentPopulationInfected desc

select *
from PercentPopulationInfected

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    ,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
    as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated




























