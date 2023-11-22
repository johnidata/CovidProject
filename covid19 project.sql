select *
from CovidDeaths
where continent is not null
order by 1,2

--select data that will be used for the project

Select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2


--What is the percentage of total deaths in total cases
--shows the likelihood of dying if you contract covid
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%ghana%'
and continent is not null
order by 1,2


-- what is the percentage of total cases in population
--shows the percentage of population who got covid
select location, date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%ghana%'
and continent is not null
order by 1,2


--what country has the highest infection rate compared to population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc


--showing countries with highest death count compared to population
select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking death count into continents
select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


select continent, MAX(total_deaths) as totaldeathcount
from CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS
select SUM(new_cases) as totalnewcases, SUM(new_deaths) as totalnewdeaths,
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)* 100 as DeathPercentage
FROM CovidDeaths
where continent is not null
--group by date
order by 1,2

--total population vs vaccination
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
Join CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 1,2,3

--using CTE
WITH popvsvac(Continent,Location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
Join CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 1,2,3
)

select *,(RollingPeopleVaccinated/population)*100
from popvsvac



--USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
Join CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
--order by 1,2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



CREATE VIEW PercentPopulationVaccinated AS
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
Join CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
