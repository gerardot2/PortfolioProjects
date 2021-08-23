select *
from CovidDeaths$
order by 3,4

-- Select data we are going to use

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths$
order by 1,2

-- Looking at Total cases vs Total deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_perc
from CovidDeaths$
order by 1,2

-- Death rate in Argentina
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_perc
from CovidDeaths$
where location like '%Argentina%'
order by 1,2

-- Total cases vs Population
-- Percentage of population infected
select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as population_infected_perc
from CovidDeaths$
where location like '%Argentina%'
order by 1,2

-- Looking at countries with highest infection rates compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as numeric)/cast(population as numeric)))*100 as population_infected_perc
from CovidDeaths$
--where location like '%Argentina%'
group by Location, Population
order by population_infected_perc desc

-- Showing countries with highest deadth count per population

select location, Max(cast(total_deaths as numeric)) as TotalDeathsCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathsCount desc

-- By continent
select continent, Max(cast(total_deaths as numeric)) as TotalDeathsCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathsCount desc


-- General numbers
-- Death percentage per day

select date, sum(cast(new_cases as numeric)) as 'Total cases', sum(cast(new_deaths as numeric)) as 'Total deaths', sum(cast(new_deaths as numeric))/(sum(cast(new_cases as numeric)))*100 as death_perc
from CovidDeaths$
--where location like '%Argentina%'
where (continent is not null) and (total_cases is not null)
group by date
order by 1,2


-- Looking total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeaths$ dea 
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE
with PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeaths$ dea 
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- Temp Table

IF OBJECT_ID('tempdb.dbo.#PercentPoplationVaccinated', 'U') IS NOT NULL
  DROP TABLE #PercentPoplationVaccinated; 

Create table #PercentPoplationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeaths$ dea 
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPoplationVaccinated


-- Cerating view to store data for later visualizations
Create View PercentPoplationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeaths$ dea 
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPoplationVaccinated