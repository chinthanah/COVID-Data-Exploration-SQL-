---Calculating death percentage for total number of cases
Select location,date,total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject.dbo.covid_death$ order by 1,2


---Looking at total cases vs population
---Looking at what percent of population are effected by covid

Select location, date, population_density, total_cases, (cast(total_cases as float)/population_density)*100 as CovidPercentage
from portfolioProject.dbo.covid_death$ order by 1,2

---Looking at the countries with highest infected rate compared to population

Select location,population_density, Max(total_cases) as highestInfectedrate, max(total_cases/population_density)*100 
as PercentagePopulationInfected
from PortfolioProject.dbo.covid_death$ 
group by location, population_density 
order by PercentagePopulationInfected desc

---Showing countries with highest death count per population
Select location, MAX(total_deaths) as Total_Death_count from PortfolioProject.dbo.covid_death$ 
where continent is not null
group by location
order by Total_Death_count desc

--Let's break things down by continent

Select continent, MAX(total_deaths) as Total_Death_count from PortfolioProject.dbo.covid_death$ 
where continent is not null
group by continent
order by Total_Death_count desc

--showing continents with highest death count per population

Select continent, MAX(total_deaths) as Total_Death_count from PortfolioProject.dbo.covid_death$ 
where continent is not null
group by continent
order by Total_Death_count desc


--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
from PortfolioProject.dbo.covid_death$ 
where continent is not null
group by date
order by 1,2

--JOINS

Select * from PortfolioProject.dbo.covid_death$ dea
join PortfolioProject.dbo.covid_vaccination$ vac
on dea.location=vac.location and
dea.date=vac.date

---Looking at totalPopulation vs Vaccination

Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covid_death$ dea
join PortfolioProject.dbo.covid_vaccination$ vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covid_death$ dea
join PortfolioProject.dbo.covid_vaccination$ vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentagePeopleVaccinated 
create table #PercentagePeopleVaccinated

(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covid_death$ dea
join PortfolioProject.dbo.covid_vaccination$ vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

Select *,(RollingPeopleVaccinated/population)*100 from #PercentagePeopleVaccinated

---Creating view to store data for later visualization

CREATE VIEW PercentageofPeopleVaccinated as
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covid_death$ dea
join PortfolioProject.dbo.covid_vaccination$ vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

Select * from PercentageofPeopleVaccinated