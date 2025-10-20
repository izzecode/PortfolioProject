-- select * from covid_vaccination
 --order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- total cases vs total death
-- shows what percentage  of pouplation with covid

select location, date, total_cases, total_deaths, (total_deaths::NUMERIC / total_cases) * 100 as death_percentage
from coviddeaths
where location like '%Nigeria'
order by 1,2;

-- total percentage of population with Covid

select location, date, total_cases, population, total_deaths, (total_cases::NUMERIC / population) * 100 as percentageInfected
from coviddeaths
where location like '%Nigeria'
order by 1,2;

-- countries with hightest infection rate to population

select location, Population, max(total_cases) as Sumoftotalcases, Max(total_cases::NUMERIC / population) * 100 as totalcasespercentage
from coviddeaths
--where location like '%Nigeria'
group by location, population
order by totalcasespercentage desc;

-- Countries with the hightest death count per population
select location,  max(total_deaths) as Totaldeaths
from coviddeaths
--where location like '%Nigeria'
group by location
order by Totaldeaths desc;

-- BREAKING IT DOWN BY CONTINENT

select CONTINENT,  max(total_deaths) as Totaldeaths
from coviddeaths
--where location like '%Nigeria'
group by continent
order by Totaldeaths desc;

-- showing the comtinent with the hightest death count

select continent, max(total_deaths) as Totaldeaths
from coviddeaths
where continent is not null
group by continent
order by Totaldeaths desc;

-- global numbers

select date, sum (new_cases) as TotalCases, sum (new_deaths) as TotalDeaths, sum (new_deaths)/sum (new_cases)*100  --total_cases, total_deaths, (total_deaths::numeric/total_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
group by date
order by 1, 2;

select sum (new_cases) as TotalCases, sum (new_deaths) as TotalDeaths, sum (new_deaths)/sum (new_cases)*100 as DeathPercentage  --total_cases, total_deaths, (total_deaths::numeric/total_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
order by 1, 2;

-- looking at the total population vs vaccinations

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
 join  covid_vaccination vac
 	on dea.location = vac.location
 	and dea.date = vac.date
 where dea.continent is not null
 order by 2,3; 

-- use CTE

WITH POPVSVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
 join  covid_vaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
	-- order by 2,3; 
 )

 select *, (RollingPeopleVaccinated/population)
 from popvsvac;


 -- temp table
DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TEMP TABLE percentpopulationvaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);

INSERT INTO percentpopulationvaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covid_vaccination vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *,
       (rollingpeoplevaccinated / population) * 100 AS percent_population_vaccinated
FROM percentpopulationvaccinated;

-- creating view to store data for later visualization

create view percentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
 join  covid_vaccination vac
 	on dea.location = vac.location
 	and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3; 

select *
from percentagePopulationVaccinated
