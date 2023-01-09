
/*
Queries used for Tableau Project using Big Query
*/


-- totcal cases, death and global death percentage of covid19
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From `covidsqltableauproject.covid_data.covid_deaths` 
where continent is not null 
order by 1,2;


-- Number of fully vaccinated people by continent
SELECT continent, MAX(people_fully_vaccinated) AS fully_vaccinated
FROM `covidsqltableauproject.covid_data.covid _vaccinations`
WHERE continent is not null 
Group by continent
ORDER BY fully_vaccinated DESC;

-- Percentage of the population affected in all countries
Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `covidsqltableauproject.covid_data.covid_deaths`
Group by Location, Population
order by PercentPopulationInfected desc;


-- Number of deaths classified by Gross National Income (GNI) 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From `covidsqltableauproject.covid_data.covid_deaths`
Where continent is null 
and location in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc;

--Number of deaths by continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From `covidsqltableauproject.covid_data.covid_deaths`
Where continent is null 
and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
