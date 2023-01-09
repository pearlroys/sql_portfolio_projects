/*
Covid 19 SQL Data Exploration using Google Big Query and Microsoft SQL
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM `covidsqltableauproject.covid_data.covid_deaths` 
WHERE continent is not null 
ORDER BY 3,4;




-- SELECT Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `covidsqltableauproject.covid_data.covid_deaths` 
WHERE continent is not null 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covidsqltableauproject.covid_data.covid_deaths` 
WHERE CONTAINS_SUBSTR(location, 'kingdom') -- ON OTHER RDMBS' WE WOULD IDEALLY USE LIKE '%kingdom%'
and continent is not null 
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM `covidsqltableauproject.covid_data.covid_deaths` 
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM `covidsqltableauproject.covid_data.covid_deaths` 
Group by Location, Population
ORDER BY PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM `covidsqltableauproject.covid_data.covid_deaths` 
WHERE continent is not null 
Group by Location
ORDER BY TotalDeathCount desc;

-- Number of fully vaccinated people by country/continent
SELECT continent, MAX(people_fully_vaccinated) AS fully_vaccinated
FROM `covidsqltableauproject.covid_data.covid _vaccinations`
WHERE continent is not null 
Group by continent
ORDER BY fully_vaccinated DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
-- to demonstrate that data types can be changed we change the integer datatype here using the CAST function into a decimal as we can still use decimals for computation

SELECT continent, MAX(cast(Total_deaths as decimal)) as TotalDeathCount
FROM `covidsqltableauproject.covid_data.covid_deaths` 
Where continent is not null 
Group by continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM `covidsqltableauproject.covid_data.covid_deaths` 
where continent is not null; 



-- Total Population vs Vaccinations an inner join is performed here
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.Date) as RollingPeopleVaccinated
FROM `covidsqltableauproject.covid_data.covid_deaths`  dea
Join `covidsqltableauproject.covid_data.covid _vaccinations` vac
  On dea.location = vac.location
  and dea.date = vac.date
where vac.new_vaccinations is not null 
AND dea.continent is not null 
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query to get the percentage of the population vaccinated byb days

With PopvsVac AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.Date) as RollingPeopleVaccinated
FROM `covidsqltableauproject.covid_data.covid_deaths`  dea
Join `covidsqltableauproject.covid_data.covid _vaccinations` vac
  On dea.location = vac.location
  and dea.date = vac.date
where vac.new_vaccinations is not null 
AND dea.continent is not null 
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS percentage_of_pop_vacc
FROM PopvsVac



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
From `covidsqltableauproject.covid_data.covid_deaths`  dea
Join `covidsqltableauproject.covid_data.covid _vaccinations` vac
Join  vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.date) as RollingPeopleVaccinated
FROM `covidsqltableauproject.covid_data.covid_deaths`  dea
Join `covidsqltableauproject.covid_data.covid _vaccinations` vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null 
