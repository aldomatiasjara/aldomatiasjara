/*
Covid 19 Data Exploration 
Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From ProjecCovid19..CovidDeaths
Where continent is not null 
order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From ProjecCovid19..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Probabilidad de morir si contrae covid en su país

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjecCovid19..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- porcentaje de población infectada con Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From ProjecCovid19..CovidDeaths
order by 1,2


-- Países con la tasa de infección más alta en comparación con la población

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjecCovid19..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Países con mayor recuento de muertes por población

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjecCovid19..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Continentes con el mayor recuento de muertes por población

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjecCovid19..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- NÚMEROS GLOBALES

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjecCovid19..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Porcentaje de población que ha recibido al menos una vacuna Covid

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProjecCovid19..CovidDeaths dea
Join ProjecCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Uso de CTE para realizar cálculos en la partición por en la consulta anterior

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProjecCovid19..CovidDeaths dea
Join ProjecCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Uso de la tabla temporal para realizar cálculos en la partición por en la consulta anterior

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
From ProjecCovid19..CovidDeaths dea
Join ProjecCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Vistas para almacenar datos para visualizaciones posteriores

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjecCovid19..CovidDeaths dea
Join ProjecCovid19..CovidVaccinations vac  
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
