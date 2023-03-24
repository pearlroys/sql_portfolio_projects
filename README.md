# sql_portfolio_projects
# Nashville Housing SQL Project and Covid 19 SQL peojects

Covid 19 SQL Data Exploration using Google Big Query and Post gres SQL

![960-covid19](https://user-images.githubusercontent.com/103274172/227508621-89856c85-3522-4619-8d4f-f76c6b64ce51.jpg)  

# Skills used: 
Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, and using 
SQL DDL (Data Definition Language) and DML (Data Manipulation Language) commands like 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', and 'DROP where used to clean, transform and analyse the data.

This nashville project analyzes housing data in Nashville, Tennessee, to provide insights into the local real estate market. The project includes an SQL database containing information on property listings, sales prices, and other housing-related metrics.

![nashvile housing](https://user-images.githubusercontent.com/103274172/227508802-8f1b980e-5c08-4909-94e0-dde947ceb329.jpeg)

 # Data Source
The data used in this project was sourced from kaggle [here](https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data)

# Database Schema
The database schema includes the following tables:

listings: Contains information on all residential property listings in Davidson County.
sales: Contains information on all residential property sales in Davidson County.
legal reference: Contains information on all zip codes in Davidson County.

# Running the Project
To run the project, follow these steps:

Clone the repository to your local machine.
Install PostgreSQL and create a new database.
Import the SQL dump file (cleaned_housing_data.sql) into your database.
Start an SQL client and connect to your database.
Run SQL queries against the database to analyze the data.
# SQL Queries
Here are some example SQL queries you can run against the database:

```Select a."ParcelID", a.PropertyAddress, b."ParcelID", b.PropertyAddress, CASE WHEN a.propertyaddress IS NULL THEN b.propertyaddress ELSE a.propertyaddress END AS newadd

--if a.propertyadress is null populate with b.propadd
From "NashvilleHousing" AS a
JOIN "NashvilleHousing" AS b
	on a."ParcelID" = b."ParcelID" --where the parcelid's are identical but on different rows by using a unique id column
	AND a."UniqueID " != b."UniqueID " 
Where a.PropertyAddress is null
```

```With PopvsVac AS 
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
```
