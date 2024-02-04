-- Data Exploration using SQL
-- Select working data
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths;

-- Total_cases vs Total_deaths
-- Shows the likelyhood of dying if you contract covid in Afghanistan
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100
as deathpercentage
from coviddeaths
where location like '%a%'
order by 1,2;

-- Total_cases vs population
-- shows the perecntage of population infected with covid
select location, date,  population, total_cases, (total_cases/population)*100
as Infectionpercentage
from coviddeaths
-- where location like '%a%'
order by 1,2;

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
as Population_infected_percentage
from coviddeaths
where continent is not null
Group by location, population
order by Population_infected_percentage desc;

-- Countries with the highest death count per population
select location, Max(Total_deaths) as TotalDeath
from coviddeaths
where continent is not null
Group by location
order by TotalDeath desc;


-- Breaking down by continent
select continent, Max(Total_deaths) as TotalDeath
from coviddeaths
where continent is not null
-- where location like '%Ni%'
Group by continent
order by TotalDeath desc;

-- Continent with the highest death count
select continent, Max(Total_deaths) as TotalDeath
from coviddeaths
where continent is not null
-- where location like '%Ni%'
Group by continent
order by TotalDeath desc;


select * from coviddeaths da join covidvaccinations vac on da.location= vac.location
and da.date = vac.date;


-- Total Population vs Vacination
-- This is used to verify the total no of people who have been vaccinated
select da.continent, da.location,da.date,da.population,vac.new_vaccinations,
sum(vac.new_vaccinations) 
over(partition by da.location order by da.location,da.date) as Roll_people_vaccinated
from coviddeaths da join covidvaccinations vac 
on da.location= vac.location
and da.date = vac.date
where da.continent is not null
order by 2,3;

-- Use CTE
with popvsvac(continent,location,date,population,Roll_people_vaccinated,new_vaccinations)
as(
select da.continent, da.location,da.date,da.population,vac.new_vaccinations,
sum(vac.new_vaccinations) 
over(partition by da.location order by da.location,da.date) as Roll_people_vaccinated
from coviddeaths da join covidvaccinations vac 
on da.location= vac.location
and da.date = vac.date
where da.continent is not null
)
select *, (Roll_people_vaccinated/population)*100 as perecentage_vaccinated
from popvsvac;


-- Temp Table
DROP TABLE IF EXISTS temp_percentage_vaccinated;

-- Create temporary table
CREATE TEMPORARY TABLE temp_percentage_vaccinated (
    continent VARCHAR(50),
    location VARCHAR(100),
    population BIGINT,
    date VARCHAR(50),
    new_vaccinations NUMERIC,
    roll_people_vaccinated NUMERIC
);

-- Insert data into temporary table
INSERT INTO temp_percentage_vaccinated
SELECT
    da.continent,
    da.location,
    da.population,
    da.date,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location, da.date) AS roll_people_vaccinated
FROM
    coviddeaths da
JOIN
    covidvaccinations vac ON da.location = vac.location AND da.date = vac.date
WHERE
    da.continent IS NOT NULL;

-- Select data and calculate percentage_vaccinated
SELECT
    *,
    (roll_people_vaccinated / population) * 100 AS percentage_vaccinated
FROM
    temp_percentage_vaccinated;


-- Creating View
create view percentage_vaccinated as
SELECT
    da.continent,
    da.location,
    da.population,
    da.date,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location, da.date) AS roll_people_vaccinated
FROM
    coviddeaths da
JOIN
    covidvaccinations vac ON da.location = vac.location AND da.date = vac.date
WHERE
    da.continent IS NOT NULL;

