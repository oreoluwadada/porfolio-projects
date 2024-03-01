/*
Covid 19 Data Exploration 

Skills used: Data formatting, Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
/* Data formatting for mysql for csv files
 UPDATE coviddeaths
SET date = DATE_FORMAT(STR_TO_DATE(date,"%d/%m/%Y" ),"%Y/%m/%d" );
update coviddeaths
 Set continent = nullif(continent,'');*/

-- general data 
(SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
where continent is not null
order by 1, 2);

(SELECT location, date,population, total_cases,  (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
-- where location like 'nigeria'
order by 1, 2);

(SELECT location, population, Max(cast(total_cases as signed)) as HighestInfectionCount, Max((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
-- where location like 'nigeria'
group by location, population, continent
order by 4 desc);

(SELECT location, population, date, Max(cast(total_cases as signed)) as HighestInfectionCount, Max((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
-- where location like 'nigeria'
group by location, population, date
order by 5 desc);


(SELECT location, max(cast(total_deaths as signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is not null  
group by location, continent
order by 2 desc);

(SELECT location, sum(cast(new_deaths as signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is null  
and location not in ('High income', 'Low income', 'European Union')
group by location
order by 2 desc); 

-- showing continents with the highest death count 
(SELECT continent, sum(cast(new_deaths as signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is not null  
group by continent
order by 2 desc); 

(SELECT continent, max(cast(total_deaths as signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is not null  
group by continent
order by 2 desc);

-- Global Numbers
(SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
order by 1, 2);
(SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
group by date
order by 1, 2);

-- looking at Total Population vs Vaccinations

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location, dea.date) as rolling_total_vax
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3);

-- USE CTE (Total Population vs Vaccination percentage)
With PopvsVac as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location, dea.date) as rolling_total_vax
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null)
Select *, (rolling_total_vax/population)*100 as rolling_total_vax_percentage 
From PopvsVac;

-- USE TEMP TABLE (total population vs Vaccination Percentage)
Drop Table if exists PercentPopulationVaccinated;

Create Table PercentPopulationVaccinated (
Continent text,
Location text,
Date text,
Population int, 
New_vaccinations text,
rolling_total_vax int);
          -- formatting to allow data insertion 
Update covidvaccinations
SET new_vaccinations = 0 where new_vaccinations = '';

Insert into PercentPopulationVaccinated 
(SELECT dea.continent, dea.location, dea.date, cast(dea.population as signed), cast(vac.new_vaccinations as signed),
sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location, dea.date) as rolling_total_vax
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null);
Select *, (rolling_total_vax/population)*100 as rolling_total_vax_percentage 
From PercentPopulationVaccinated;

-- WITHOUT CTE/Temp Table (total population vs Vaccination Percentage)
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location, dea.date) as rolling_total_vax,
(sum(vac.new_vaccinations) over (partition by dea.location, dea.date)/dea.population)*100 as rolling_total_vax_percentage
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3);

-- Creating view to store data for later visualisation
Create View PercentPopulationVacccinated as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location, dea.date) as rolling_total_vax,
(sum(vac.new_vaccinations) over (partition by dea.location, dea.date)/dea.population)*100 as rolling_total_vax_percentage
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3);


