# Report: homicidios-determinantes

## Answer

Across territories, homicide rates are most consistently associated with socioeconomic disadvantage [s7] [s26]:
- Poverty and deprivation are "among the strongest and most stable predictors" in more than 200 macro-level studies [s7].
- Inequality is among the strongest cross-national predictors [s4], and a cross-country panel reads its effect as causal [s8].
- Of 76 aggregate correlations of violent crime with poverty or inequality, "all but 2, or 97 percent, were positive" [s26].
- Whether inequality survives once poverty is controlled is disputed: in replications, it "disappeared in two of three models" [s3].

In Brazilian municipalities, homicide is higher where municipalities are larger, more urbanized, less literate and more unequal. Absolute income and poverty have the highest risk in the intermediate categories [s12]. A larger share of young men [s11], or of young people [s24] [s31], goes with more homicide.

Geography and institutions explain much of the rest [not in sources]:
- the shift toward the North, the Northeast and the interior [s27] [s18] [s31];
- borders and trafficking routes [s31] [s22];
- faction conflict [s5] [s17];
- firearms [s21].

None of these are in the Censo. Brazilian models absorb differences between states with state dummies [s24] or by nesting municipalities in states [s31].

## Theoretical framework

Five macro theories predict how inequality and income relate to violence [not in sources]:
- **Strain/anomie.** Some social structures "exert a definite pressure upon certain persons in the society to engage in nonconformist rather than conformist conduct" when goals outrun legitimate means [s44]. Tests of classic anomie have mostly failed; the General Strain Theory version found support in individual-level data [s16].
- **Relative deprivation.** In 125 US metropolitan areas, "economic inequality generally, increases rates of criminal violence, but once economic inequalities are controlled poverty no longer influences these rates" [s34]. Deprivation theories "receive strong empirical support" across more than 200 studies [s7].
- **Social disorganization.** Structural disadvantage weakens local networks, and between-community variations in disorganization "transmit much of the effect of community structural characteristics" on crime, according to tests in British localities [s35]. In Brazil, it predicts rising municipal homicide trajectories [s13].
- **Economic theory of crime.** "a person commits an offense if the expected utility to him exceeds the utility he could get by using his time and other resources at other activities" [s37]. Inequality "has no effect on property crime but a strong and robust impact on violent crime", which strain and disorganization explain better [s33].
- **Institutional anomie and development.** Homicide varies inversely with the "decommodification of labor" [s36]. Crime follows "an inverted U-shaped pattern" as income rises [s39]. Inequality predicts homicide in countries "with a medium level of human development" [s40]. Inequality conditions the effect of GDP on homicide [s41], although with country fixed effects the inequality effect "might be spurious" [s43].

## Proposed research question

**Main question** [not in sources]: which socioeconomic, demographic, educational and territorial characteristics of Brazilian municipalities are associated with the homicide rate of 2021–2023, measured with Censo 2022 data?

Sub-questions:
- **Inequality or poverty?** Does inequality stay associated with homicide once poverty is in the model? The literature splits on this [s3] [s8], and inequality's predictive strength fell from 2010 to 2017 [s18].
- **Is income non-linear?** Is the income association highest at intermediate levels, as the poverty and income categories suggest [s12]?
- **How much is between states?** How much of the variation lies between states, which stand in for registration differences, police and justice institutions [s24] [s29], and plausibly for factions too, which the Censo cannot measure [not in sources]?
- **Border and Amazon.** Do border and Amazon municipalities keep higher rates after the socioeconomic controls [s31] [s22]?

Why this question [not in sources]: it is the established structural-covariate design, applied to the newest data. No recorded national study uses Censo 2022 covariates. Each sub-question tests a point the literature disputes or reports only with older data.

## Recommended methodology

Each step names the study it follows. Steps inside the course apostila are the main method. Anything else is listed at the end for the group to decide [not in sources].

1. **Outcome.** Homicides X85 a Y09 plus Y35 a Y36, by municipality of residence, summed over several years to stabilize the rates, as in [s12]. We use the three most recent years [not in sources].
2. **Scope.** Small-municipality rates are imprecise [s32], and the Atlas advises against per-capita rates for them [s23]. In [s12], 1.324 zero-rate municipalities left the log model inadequate. [s32] recommends Bayesian correction and [s12] kept small municipalities, so excluding them is our own choice: OLS on log(rate) has no zeros above the cut-off, and the apostila covers no rate smoothing. We use 20 mil habitantes and state the choice as a limitation [not in sources].
3. **Model.** Multiple linear regression of the log rate on logged covariates, read as elasticities. This borrows the specification of the national template [s24], which itself adds a spatial-dependence term. We fit it by OLS and choose the outcome transformation with Box-Cox, which is in the apostila [not in sources].
4. **Predictors, by block** [not in sources]:
   - Socioeconomic: ln income (non-linear, after [s12]), inequality, poverty and unemployment [s3] [s18].
   - Demographic: % young men [s11] and % urban [s12]. Density is our addition [not in sources].
   - Education: literacy and school attendance [s10] [s12].
   - Territory: border [s31], Amazon [s22] [s30] and state (UF) indicators [s24].
5. **Collinearity.** Report VIFs, and avoid entering income, poverty and literacy together without a check. Collinearity among structural covariates made estimates unstable [s1], and [s31] had to enter correlated covariates one at a time.
6. **Inequality against poverty.** Fit the model with both, and use a partial F test for inequality given poverty. This answers the debate between [s3] and [s8] for Brazilian municipalities [not in sources].
7. **Non-linear income.** [s12] found the highest risk in intermediate income and poverty categories, with "associações peculiares (cúbicas)". We approximate this with an income² term tested by partial F [not in sources].
8. **States.** Include UF indicators, as [s24] did with state dummies. Compare with region indicators through a nested F test [not in sources].
9. **Diagnostics.** Check residuals against fitted values, normality, constant variance and influential points. These are the problems [s12] met with linear models: "homocedasticidade e normalidade". Check whether neighbouring municipalities' residuals are correlated, because homicide clusters in space [s25] [s24].
10. **Interpretation.** Read the results as municipal associations, not individual risk or causation. [s12] notes the "dificuldades em atribuir ao nível individual". Cross-national research relies overwhelmingly on cross-sectional designs [s4], and ours is cross-sectional too [not in sources].
11. **Outside the apostila, for the group to decide** [not in sources]:
    - Binomial or Bayesian space-time models [s31].
    - Fractional logit [s12].
    - Empirical Bayes smoothed rates [s32].
    - Spatial lag regression [s24].
    - If used, each would be a robustness check, flagged as outside the apostila [not in sources].

## Main studies

### [s12] Duarte et al. (2012): all municipalities, men aged 20–39
- **Data and measures**: all municipalities (5.565), SIM deaths of men of 20 a 39 anos by residence, aggregated over quadrennia. The predictors are size, fertility, literacy, % low income, mean income, the renda 20/40 ratio, % urban and sex ratio, in approximate quartiles [s12].
- **Model**: linear regression on the original rate violated "homocedasticidade e normalidade". The log transform "minimizou tal violação", but the zeros ("n=1.324 municípios") still left it inadequate, so they used a "modelo logit fracional" [s12].
- **Conclusions**: risk rises with size, fertility, inequality and urbanization, and falls with literacy. At 10 to 12 times inequality the average excess is 9,3 (IC95%: 5,3 a 13,3) deaths per 100 mil. Poverty and income show "associações peculiares (cúbicas)" [s12].
- **What we take**: our outcome definition and multi-year averaging, the warning that zeros break OLS on log(rate), and the case for a non-linear income term [not in sources].

### [s24] Carvalho, Cerqueira & Lobão (IPEA): the national template
- **Data and measures**: 5.507 municipalities, 1999 to 2001, with the homicide victimization risk as outcome. Covariates for 2000 in logs: employment, wages, sanitation, youth (15 to 24), urban share, poor children, children out of school, adolescent parents, illiterate children, the Gini index and poverty intensity [s24].
- **Model**: regression with spatial dependence (parameter 0.382), plus state dummies, keeping "only the significant state dummies" [s24].
- **Conclusions**: "In all cases, the parameters were statistically significant and confirmed expectations", with "the enormous influence of income inequality" [s24].
- **What we take**: a log-log OLS with elasticities, state indicators, and both inequality and poverty in the model [not in sources].

### [s3] Pridemore: Poverty Matters
- **Data and measures**: countries; replications of two studies with inequality and overall and sex-specific homicide rates, then with a poverty measure added [s3].
- **Model**: the original specifications re-estimated with poverty, across "different samples, data years, measures of inequality" and "estimation procedures" [s3].
- **Conclusions**: "there was a positive and significant poverty–homicide association, while the inequality–homicide association disappeared in two of three models" [s3].
- **What we take**: put % poor next to inequality, and test whether inequality survives (step 6) [not in sources].

### [s1] Land, McCall & Cohen: collinearity among structural covariates
- **Data and measures**: cities, metropolitan areas and states in 1960, 1970, and 1980, with 11 structural covariates [s1].
- **Model**: a baseline regression, then "Principal components analysis" and re-estimation [s1].
- **Conclusions**: instability "because of high levels of collinearity among several regressors", which was "greatly reduced" after principal components [s1].
- **What we take**: the VIF step and the care with correlated socioeconomic covariates (step 5) [not in sources].

### [s31] Nsoesie et al.: a recent national municipal model
- **Data and measures**: SIM homicides by municipality, 2000 to 2014; metro region, border strip, crude domestic product, urbanization and the share aged 15–29 [s31].
- **Model**: a hierarchical Bayesian space-time model with the rate "modeled as a binomial random variable", Besag spatial effects and municipalities nested within states. Covariates were entered separately "due to significant correlations between covariates" [s31].
- **Conclusions**: metro region RR 1.44 (95% CI 1.38–1.52), border strip 1.151, crude domestic product 1.18, share aged 15–29 1.07. The results support dissemination and interiorization [s31].
- **What we take**: expected signs for border, urban and youth. Its model is a robustness option outside the apostila [not in sources].

The other 27 sources, with their data, measures, model and conclusions, are in `bibliography.md` [not in sources].

## Our variables against the evidence

| Our variable | Evidence | Expected sign | Status |
|---|---|---|---|
| ln income + income² | Intermediate-category peak for income and poverty [s12]; development weak cross-nationally [s4] | Inverted U | Supported (Brazil) [s12] |
| Inequality (mean/median ratio) | Gini or 20/40 positive [s8] [s12] [s24]; fragile once poverty is controlled [s3]; weaker after 2010 [s18] | + | Supported, disputed [s3] [s8] |
| Poverty (% poor) | Among the most stable predictors [s7] [s3]; poverty intensity used in Brazil [s24] | + | Supported; missing from the scratch model [s3] |
| Unemployment | Prominent in Brazilian reviews [s10]; rising predictive strength 2010–2017 [s18] | + | Supported (moderate) [s10] [s18] |
| % urban, ln density, size | Larger and more urbanized municipalities have higher risk [s12] [s23]; urbanization predicts levels [s31] and growth [s18] | + | Supported [s12] |
| % men 15–29 | Strong for young males in São Paulo [s11]; modest for the share aged 15–29 nationally, RR 1.07 [s31]; weak abroad [s14] [s4] | + | Supported, disputed [s11] [s14] |
| Literacy / school attendance | Protective [s10] [s12]; education spending elasticity of about 0,1 [s15] | − | Supported [s10] [s12] |
| Dropout, age-grade distortion | Only indirect support from general education evidence [s10] | + | Theory only [s10] |
| Recent migration | Disorganization theory [s13]; no direct municipal test recorded | + | Theory only [s13] |
| Amazônia Legal, border strip | Border RR 1.151 [s31]; trafficking routes [s22]; Amazon faction disputes [s30] | + | Supported [s31] [s22] |
| State (UF) | State dummies [s24]; municipalities nested in states [s31]; state criminal-justice policies [s29] | — | Supported [s24] [s31] |
| % undetermined intent | Hidden homicides among deaths of undetermined intent [s23] | control | Data quality [s23] |

## Settled
- Concentrated disadvantage, including poverty, is among the strongest and most stable macro-level predictors. Criminal-justice variables other than incarceration are among the weakest [s7].
- Poverty and inequality are each positively associated with violent crime in aggregate data, with variation in size [s26].
- Structural covariates are highly collinear. This makes single estimates unstable, and combined indices restore consistency [s1] [s2].
- In Brazil, homicide shifted from the Southeast toward the Northeast and North, and toward the interior [s27] [s18] [s31]. In 2023, state rates ranged from 6,4 in São Paulo to 57,4 in Amapá [s17].
- Homicide is higher in larger and more urbanized Brazilian municipalities [s12] [s23].
- Homicide clusters in space between neighbouring areas [s25] [s24].
- Rates for small municipalities are imprecise; zeros and extreme values come from small numbers [s32] [s12] [s23].
- Education appears protective in Brazilian studies [s10] [s12] [s15].

## Disputed
- **Inequality versus poverty** [s3] [s8]:
  - Inequality causes homicide across countries [s8], and in Brazil it has an "enormous influence" [s24].
  - The inequality effect largely disappears once poverty is controlled [s3]. In large Brazilian municipalities, inequality is robust "principalmente para os crimes contra o patrimônio" [s9]. Its predictive strength fell from 2010 to 2017 [s18].
- **Age structure** [s11] [s14]:
  - A 1% rise in young males causes a 4.5% rise in homicides [s11]. Ageing is one of the factors that "potencialmente" contributed to Brazil's recent decline [s17].
  - Age structure has "a limited impact on aggregate crime rates" [s14], and static population indicators are weak cross-national predictors [s4].
- **The São Paulo decline** [s20] [s19] [s6]:
  - policing and gun control [s20];
  - demography [s11];
  - PCC monopoly, supported at favela level [s19] but not at state level [s6];
  - faction-conflict dynamics [s5].
- **Firearms** [s21] [s29]:
  - Gun prevalence raises homicide, and the 2003 law saved lives [s21].
  - Legal gun ownership is "unlikely to be a significant driver" [s29].

## Open
- No recorded study tests migration, school dropout or age-grade distortion as municipal predictors of homicide [not in sources].
- No recorded quantitative study estimates the effect of the PCC–CV war on municipal rates. The evidence is ethnographic [s5] or descriptive [s17] [s30].
- No recorded national municipal study uses the newest Censo covariates, and none tests an inverted U in income together with an inequality × income interaction for Brazilian municipalities [not in sources].
- The closest precedents for that test are cross-national or OECD studies [s40] [s41] and the intermediate-category pattern in [s12].
- Unemployment is prominent in Brazilian studies [s10], and its predictive strength rose from 2010 to 2017 [s18], but no recorded source gives a comparable effect size [not in sources].
- Cross-national research relies overwhelmingly on cross-sectional designs [s4]. Most of the sources recorded here are cross-sectional too [not in sources].

## Read first
1. [s12] Duarte et al.: same unit and outcome as ours, and why OLS on log(rate) struggles with zeros. Read Métodos and Tabela 3.
2. [s24] Carvalho, Cerqueira & Lobão: the template. Read pp. 16–17.
3. [s3] Pridemore: the critique a model with inequality and no poverty must answer. Read the abstract.
4. [s1] Land, McCall & Cohen: collinearity among structural covariates. Read the abstract.
5. [s31] Nsoesie et al.: a recent national model with border and youth effects. Read Methods and Results.

## Conclusion

Homicide is not spread at random across Brazilian municipalities. International reviews agree that places with more poverty and deprivation have more crime and violence [s7] [s26]. In Brazil, homicide is higher in larger, more urban, less literate and more unequal municipalities, but the risk peaks at intermediate poverty rather than at the poorest places [s12]. Inequality shows up strongly in several studies [s8] [s24] [s26], but it is not settled whether it matters beyond poverty [s3]. Our data can test exactly that [not in sources].

Some of the differences come from things the Censo does not measure. Criminal factions [s5], guns [s21] and each state's justice system and institutions [s29] each play a role. No source estimates how large a share each explains [not in sources]. The violence has also moved toward the North, the Northeast and the interior [s27] [s31]. A model with state indicators captures these differences as a block, but it cannot say which of them is at work [not in sources].

For our work, the literature gives a clear and defensible path within the course methods [not in sources]:
- multiple linear regression of the log rate on municipal characteristics, with the specification of the national template [s24] but fitted by OLS [not in sources];
- rates averaged over several years [s12], and, by our own choice, only municipalities large enough for stable rates, given how imprecise small-municipality rates are [s32] [not in sources];
- poverty next to inequality [s3], a non-linear income term [s12], collinearity checked [s1], and state indicators [s24].

The results will describe associations between places, not causes of individual violence [s12].
