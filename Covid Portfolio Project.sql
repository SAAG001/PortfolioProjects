Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations$']
--order by 3,4

--Select data that we would be using

Select Location, date, total_deaths, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
order by 1,2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_deaths, total_cases,(cast(total_deaths as float)/cast(total_cases as float))*100 as Deathpercentage
From PortfolioProject..['Covid Deaths$']
Where location like '%Nigeria%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid.

Select Location,date,population,total_cases,(cast(population as float)/cast(total_cases as float))*100 as Deathpercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '%Nigeria%'
order by 1,2

--Looking at countries with High Infection Rate Compared to Population

Select Location, population, Max(total_cases) as HighestInfectioncount, Max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths$']
--Where location like '%Nigeria%'
Group by location,population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count Per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%Nigeria%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Breakdown of data by Continent.

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths
 as int))/SUM(New_cases)*100 as Deathpercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '%Nigeria%'
where continent is not null
--Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, Location,Date,Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac




--Temp Table

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create view PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PopulationVaccinated