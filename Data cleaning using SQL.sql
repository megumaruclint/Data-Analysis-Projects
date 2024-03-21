SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
  FROM [PorfolioProject].[dbo].[CovidDeaths]

  SELECT Location, date, total_cases, new_cases,total_deaths,population
From CovidDeaths
ORDER BY 1, 2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Nigeria


SELECT Location, date, total_cases, new_cases,total_deaths, ( total_deaths/total_cases) *100 AS DeathPercentage
From CovidDeaths
WHERE Location LIKE '%Nigeria'
ORDER BY 1,2

-- Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases,  ( total_cases/population) *100 AS Percentpopulationinfected
From CovidDeaths
WHERE Location LIKE '%Nigeria'
ORDER BY 1,2

-- Countries  with highest infection rate compared to population

SELECT Location,  population, MAX (total_cases) AS HighestInfectioncount,  MAX(( total_cases/population)) *100 AS percentpopulationinfected
From CovidDeaths
--WHERE Location LIKE '%Nigeria
GROUP BY continent, population
ORDER BY percentpopulationinfected desc

-- Showing countries with hihgest death count per population

SELECT Location,  MAX (CAST (Total_deaths as INT)) as Totaldeathcount
From CovidDeaths
--WHERE Location LIKE '%Nigeria
WHERE continent is null
GROUP BY continent
ORDER BY Totaldeathcount desc

-- Breaking things down by continent

SELECT continent,  MAX (CAST (Total_deaths as INT)) as Totaldeathcount
From CovidDeaths
--WHERE Location LIKE '%Nigeria
WHERE continent is not null
GROUP BY continent
ORDER BY Totaldeathcount desc


--Showing the continent with the hihgest death count per population

SELECT Location,  MAX (CAST (Total_deaths as INT)) as Totaldeathcount
From CovidDeaths
--WHERE Location LIKE '%Nigeria
WHERE continent is not null
GROUP BY continent 
ORDER BY Totaldeathcount desc


-- Global Numbers

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%Nigeria'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date ) AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
 ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 2,3



  --Using CTE 

 WITH popsvac (continent, location, date, population, new_vaccination, Rollingvaccinated)
 AS
 (
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert(INT,vac.new_vaccinations )) OVER (partition by dea.location ORDER BY dea.location, dea.date ) AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
 ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not null
 -- ORDER BY 2,3
  )
  SELECT*, (Rollingvaccinated/population)*100
  FROM popsvac



  --TEMP TABLE

 DROP TABLE IF EXISTS #Percentpopulationvaccinated

 CREATE TABLE #Percentpopulationvaccinated
  (
  continent NVARCHAR (200),
  Location NVARCHAR (200),
  Date DATETIME,
  Population NUMERIC,
  New_vaccination NUMERIC,
  Rollingpeoplevaccinated NUMERIC
  )

  INSERT INTO #Percentpopulationvaccinated

SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert(INT,vac.new_vaccinations )) OVER (partition by dea.location ORDER BY dea.location, dea.date ) AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
 ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not null
 -- ORDER BY 2,3

 SELECT*, (Rollingpeoplevaccinated/population)*100
  FROM #Percentpopulationvaccinated


  -- Creating view to store data for later visualization

  CREATE VIEW Percentpopulationvaccinated AS
  SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert(INT,vac.new_vaccinations )) OVER (partition by dea.location ORDER BY dea.location, dea.date ) AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
 ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not null
 -- ORDER BY 2,3
  
