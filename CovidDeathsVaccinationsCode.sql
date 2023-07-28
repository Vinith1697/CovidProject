/*Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

Select * 
From PortfolioProject..CovidVaccinations
order by 3, 4*/

--Select the data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--altering columns from nvarchar to float
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float;

--Looking at total cases vs total deaths
--likelihood of dying if you get covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'India'
and continent is not null
order by 1,2

--Looking at countries with highest inferction rate compared to population
Select location, population, MAX(total_cases) as HighestInfectedCountry, MAX(total_cases/population)*100 as HighestPopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--Where location = 'India'
Group BY location, population
order by HighestPopulationInfectionPercentage desc

--Showing countries with the highest death count per Population
Select location, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
where continent is not null
--Where location = 'India'
Group BY location
order by TotalDeaths desc

--Lets break this by continent
Select location, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
where continent is null
--Where location = 'India'
Group BY location
order by TotalDeaths desc

--continents with highest death count
Select continent, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
where continent is not null
--Where location = 'India'
Group BY continent
order by TotalDeaths desc


--Global numbers
Select SUM(total_cases), SUM(total_deaths), SUM(total_deaths)/SUM(total_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths

where continent is not null
--group by date
order by 1,2

--Looing at total population vs total vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--I wanted to divide the rollingpeoplevaccinated with the population to find out how much of the population are getting vaccinated
--but it turns out that we can't use the column which we just created with calculation to do further calculations
-- So I'll have to use CTE
With PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopVsVac

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated
