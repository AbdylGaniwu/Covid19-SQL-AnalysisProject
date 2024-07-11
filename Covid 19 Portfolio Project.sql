
-- Covid Death Data Table
SELECT *
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Covid Vaccination Data Table
SELECT *
FROM PortfolioProject..CovidVaccinationsData
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Selected Data Table Columns
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
ORDER BY 5;

-- Total Cases vs Total Deaths in Ghana
SELECT location, date, total_cases, total_deaths, 
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeathData
WHERE location LIKE '%Ghana%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Total Cases vs Population in Ghana
SELECT location, date, population, total_cases, 
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeathData
WHERE location LIKE '%Ghana%'
ORDER BY 1, 2;

-- Countries with Highest Infection Rate compared with Population
SELECT location, population, MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount, 
    MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers (New Cases, Total Deaths, Death Percentage)
SELECT date, SUM(CAST(new_cases AS FLOAT)) AS Total_cases, 
    SUM(CAST(new_deaths AS FLOAT)) AS Total_deaths, 
    (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeathData
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Total Population vs Total Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeathData dea
JOIN PortfolioProject..CovidVaccinationsData vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Common Table Expression (CTE)
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeathData dea
    JOIN PortfolioProject..CovidVaccinationsData vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PeopleVaccinatedRate
FROM PopvsVac;

-- Temporary Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeathData dea
JOIN PortfolioProject..CovidVaccinationsData vac
    ON dea.location = vac.location AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PeopleVaccinatedRate
FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeathData dea
JOIN PortfolioProject..CovidVaccinationsData vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;
