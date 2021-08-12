Select *
From CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [dbo].[CovidVaccination]
--order by 3,4

--Selecting the data which is going to be used
Select location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths
where continent is not null
order by 1,2

--Going to Analyze Total Cases VS Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like'%India%'
and continent is not null
order by 1,2

--Going to Analyze Total Deaths VS Population
Select location,date,population,total_deaths,(total_deaths/population)*100 AS DeathPercentage
From CovidDeaths
Where location like'%India%'
and continent is not null
order by 1,2

--Going to Analyze Total Cases VS Population
Select location,date,population,total_cases,(total_cases/population)*100 AS CasesPercentage
From CovidDeaths
Where location like'%India%'
and continent is not null
order by 1,2

--Analyzing the Country with Highest Infection Rate compared to the Population
Select location,population,max(total_cases) as Highest_Infection_Count,max((total_cases/population))*100 AS PopulationInfectedPercentage
From CovidDeaths
--Where location like'%India%'
Group by location ,population
order by PopulationInfectedPercentage desc

--Analyzing by Continent

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like'%India%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From CovidDeaths
--Where location like'%India%'
Where continent is not null
--GROUP BY date
order by 1,2


--Analyzing Total Population VS Total Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date)
as rollingpepoplevaccinated
From CovidDeaths dea
join CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
	order by 2,3



	--Using CTE
With PopvsVac (Continent,Location,Date,Population,rollingpepoplevaccinated,new_vaccinations)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date)
as rollingpepoplevaccinated

From CovidDeaths dea
join CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--rder by 2,3
)
Select *,(rollingpepoplevaccinated/Population)*100 AS rollingpepoplevaccinated_percentage
From PopvsVac


--Temp Tablet
Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpepoplevaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date)
as rollingpepoplevaccinated

From CovidDeaths dea
join CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--rder by 2,3

Select *,(rollingpepoplevaccinated/Population)*100 
From #PercentPeopleVaccinated

--creating view to store data for later visulization
Create View PercentPeopleVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date)
as rollingpepoplevaccinated

From CovidDeaths dea
join CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select*
From PercentPeopleVaccinated


