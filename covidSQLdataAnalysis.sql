Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by location,date


-- Selecting the data we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by location, date


-- Total Cases vs Total Deaths

Select Location, date, Total_Deaths, Total_Cases,
	CASE
		WHEN TRY_CONVERT(float, Total_Deaths) IS NOT NULL AND TRY_CONVERT(float, Total_Cases) IS NOT NULL 
		THEN (CONVERT(float, Total_Deaths) / CONVERT(float, Total_Cases)) * 100
    ELSE NULL
	END AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United Kingdom'
and continent is not null 
order by location,date


-- Total Cases vs Population
-- Shows what percentage of population were infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'United Kingdom'
order by location,date


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
-- New cases and new deaths, death percentage for each year

SELECT 
    YearOnly AS year,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) <> 0 THEN 
            (SUM(CAST(new_deaths AS int)) * 100.0) / NULLIF(SUM(new_cases), 0)
        ELSE 0
    END AS DeathPercentage
FROM (
    SELECT 
        date,
        YEAR(date) AS YearOnly,
        new_cases,
        CAST(new_deaths AS int) AS new_deaths
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL 
) AS YearlyData
GROUP BY YearOnly
ORDER BY year;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select continent, location, date, population, new_vaccinations, 
SUM(CONVERT(bigint, new_vaccinations)) OVER (Partition by Location Order by location, Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths
where continent is not null 
order by location,date
