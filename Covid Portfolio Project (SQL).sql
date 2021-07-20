SELECT *
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

--Select data that we are going to be using

--Looking at covid death rate percantages by location
SELECT
location,
date,
total_cases,
total_deaths,
ROUND((total_deaths/total_cases)*100,2) as Death_Rate_Perc
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT
location,
date,
total_cases,
population,
ROUND((total_cases/population)*100,2) as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE location = 'United States'
ORDER BY 2

--What countries have the highest infection rates
SELECT
location,
MAX(total_cases) Max_Cases,
MAX(population) Population,
MAX(total_cases/population) * 100 highest_infection_rate
FROM [Portfolio Project]..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC

--Highest Death Count Per Population
SELECT 
location,
MAX(CAST(total_deaths as int)) Max_Deaths,
MAX(population) Population,
MAX(CAST(total_deaths as int)/population) * 100 highest_death_rate
FROM [Portfolio Project]..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Break Things down by continent

--Continents with the highest death count by population

SELECT
continent,
MAX(CAST(total_deaths as int)) total_deaths
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP by continent
ORDER BY 2 DESC

--Global Numbers

SELECT
date,
SUM(new_cases) New_cases,
SUM(CAST(new_deaths as int)) New_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date

-- Joining both tables
--Rolling # of Vaccinations
SELECT
d.date,
d.continent,
d.location,
d.population,
d.total_cases,
d.total_deaths,
SUM(CAST(new_tests as int)) OVER (Partition BY d.location ORDER BY d.date) rolling_people_vaccinated,
d.new_cases,
d.new_deaths,
v.new_tests
FROM [Portfolio Project]..CovidDeaths$ d
JOIN [Portfolio Project]..CovidVaccinations$ v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 3,1


-- Create CTE popvacs

WITH popvacs as
(
SELECT
d.date,
d.continent,
d.location,
d.population,
d.total_cases,
d.total_deaths,
SUM(CAST(new_tests as int)) OVER (Partition BY d.location ORDER BY d.date) rolling_people_vaccinated,
d.new_cases,
d.new_deaths,
v.new_tests
FROM [Portfolio Project]..CovidDeaths$ d
JOIN [Portfolio Project]..CovidVaccinations$ v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 3,1
)

SELECT 
p.*,
(rolling_people_vaccinated/p.population) * 100 as PercofPopVaccinated
FROM popvacs p

-- Create a view for later data visualization

CREATE View RollingNumOfVacc AS
(SELECT
d.date,
d.continent,
d.location,
d.population,
d.total_cases,
d.total_deaths,
SUM(CAST(new_tests as int)) OVER (Partition BY d.location ORDER BY d.date) rolling_people_vaccinated,
d.new_cases,
d.new_deaths,
v.new_tests
FROM [Portfolio Project]..CovidDeaths$ d
JOIN [Portfolio Project]..CovidVaccinations$ v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL)
