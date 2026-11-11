# Mission: homicidios-determinantes

## Question
Which socioeconomic, demographic, educational, territorial and institutional factors are associated with homicide rates across territorial units (municipalities, counties, regions, countries), in Brazil and abroad, and how strong and consistent are these associations?

## Why
The answer grounds a municipal-level multiple linear regression of homicide rates (2021–2023, SIM/DATASUS, 5,570 Brazilian municipalities, Censo 2022 predictors) for the GED-16 regression course at ITA (ODS 16, indicator 16.1.1). It decides which explanatory variables enter the model, what sign each one is expected to have, and which studies the article's literature section cites. The deliverable is a Quarto report in R.

## Areas
Socioeconomic factors: income inequality, poverty, income level and unemployment, and the theories that link them to homicide (relative deprivation/strain, social disorganization).
Demography and education: the share of young men, schooling, school dropout and age-grade distortion, urbanization and density, and migration.
Theory: the classic macro theories of crime and violence (relative deprivation/strain, social disorganization, the economic theory of crime, institutional anomie, modernization and the development–violence curve), as primary works and with their empirical tests.
Territory and institutions: drug trafficking and criminal factions (PCC, CV), the interiorization of violence in Brazil, Amazon and border regions, and differences between states (policing, state capacity).

## Bounds
- Ecological studies, meaning the unit is a territory and not an individual. Brazilian municipal and state studies come first, with international cross-national and US county/city studies as comparison.
- Record the method each study uses (OLS on transformed rates, count models, spatial models), but do not survey methods as a subject of its own.

## Depth
use

## Out of scope
- Race or skin colour as a determinant (the user removed it from the study).
- A separate review of statistical methods and of SIM data quality (undercount, undetermined intent).
- Individual-level victimization studies, policing-intervention evaluations and other crimes (robbery, property crime), unless they directly explain homicide rates across territories.

## Background
The user and their group already built a preliminary model: OLS on ln(rate) for municipalities with 20,000 or more inhabitants. Its predictors were log income (with a quadratic term), inequality as the mean/median income ratio, unemployment, % urban, log density, % young men aged 15–29, school attendance at ages 15–17, high-school dropout and age-grade distortion, recent migration, Amazônia Legal, border strip and state (UF) fixed effects. The user considers it a scratch made for the pitch and wants the choices to be grounded in literature.
