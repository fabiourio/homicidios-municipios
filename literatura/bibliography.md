# Bibliography: homicidios-determinantes

<!-- One entry per source, most important for our question first. Facts cite the ledger id; Relevance is our own reading. Details the saved text does not give are marked as not stated. -->

## [s12] Duarte et al. (2012), Associação ecológica entre características dos municípios e o risco de homicídios em homens adultos de 20-39 anos de idade no Brasil, 1999-2010

- **Reference**: Elisabeth Carmen Duarte, Leila Posenato Garcia et al., Ciência & Saúde Coletiva [s12].
- **Data and unit**: all Brazilian municipalities (5.565 in the analytical stage), with SIM deaths of men of 20 a 39 anos by municipality of residence. Rates are aggregated in quadrennia "buscando também alcançar maior estabilidade", and the cross-section is 2007 a 2010 [s12].
- **Measures**: the outcome is homicides (X85 a Y09, Y35 a Y36) per 100 mil men. The predictors are population size, fertility rate, literacy, % low income, mean per capita income, the renda 20/40 inequality ratio, % urban and sex ratio. All except size are categorized in approximate quartiles, without assuming linearity ("sem pressupor linearidade") [s12].
- **Model**: linear regression first, on the original rate and then on its log. Residuals violated "homocedasticidade e normalidade", and the zeros ("n=1.324 municípios") left the log model inadequate, so they used a "modelo logit fracional" with marginal effects and Pearson-residual checks [s12].
- **Conclusions**: risk rises with population size, fertility, inequality (renda 20/40) and urbanization, and falls with literacy. At 10 to 12 times inequality, the average excess is 9,3 (IC95%: 5,3 a 13,3) deaths per 100 mil. Poverty and mean income show "associações peculiares (cúbicas)", with the highest risk in the intermediate categories [s12].
- **Relevance**: the closest precedent for our data and pipeline. It shows why OLS on log(rate) breaks with the zeros of small municipalities. That supports our population cut-off, the multi-year average and a non-linear income term [not in sources].

## [s24] Carvalho, Cerqueira & Lobão (2015, first released 2005), Socioeconomic Structure, Self-fulfilment, Homicides and Spatial Dependence in Brazil

- **Reference**: Alexandre Carvalho, Daniel Cerqueira, Waldir Lobão, IPEA Discussion Paper (originally TD) [s24].
- **Data and unit**: 5.507 Brazilian municipalities, 1999 to 2001. The outcome is "the risk of a resident in any given municipality being a victim of homicide" [s24].
- **Measures**: covariates for 2000, all in logarithms: employment rate, average wages, households without a toilet, proportion of young people (15 to 24), proportion urban, poor children, children not attending school, adolescent parents, illiterate children, the Gini index and the intensity of poverty [s24].
- **Model**: regression with spatial dependence, with a spatial parameter of 0.382. Dummies for all states were included, then "we kept only the significant state dummies" [s24].
- **Conclusions**: "In all cases, the parameters were statistically significant and confirmed expectations". The authors note "the enormous influence of income inequality" [s24].
- **Relevance**: our template, with the same unit and covariate types. It supports logged covariates read as elasticities, state indicators, and including both inequality and poverty [not in sources].

## [s3] Pridemore (2011), Poverty Matters: A Reassessment of the Inequality-Homicide Relationship in Cross-National Studies

- **Reference**: William Alex Pridemore, The British Journal of Criminology [s3].
- **Data and unit**: countries, replicating "two prior studies in which a significant inequality–homicide association was found" [s3].
- **Measures**: inequality, poverty, and overall and sex-specific homicide rates [s3].
- **Measures as reported by citing papers (unverified)**: the Gini for inequality, and infant mortality as the poverty proxy; the replicated studies seem to be Fajnzylber et al. (2002) and Savolainen (2000). The paper's methods were not read [not in sources].
- **Model**: the original models were replicated, then re-estimated with "a measure of poverty". Results held across "different samples, data years, measures of inequality" and "estimation procedures" [s3].
- **Conclusions**: "there was a positive and significant poverty–homicide association, while the inequality–homicide association disappeared in two of three models" [s3].
- **Relevance**: any model of ours with inequality must also include poverty and report whether inequality survives [not in sources].

## [s1] Land, McCall & Cohen (1990), Structural Covariates of Homicide Rates: Are There Any Invariances Across Time and Social Space?

- **Reference**: Kenneth C. Land, Patricia L. McCall, Lawrence E. Cohen, American Journal of Sociology [s1].
- **Data and unit**: cities, metropolitan areas and states in 1960, 1970, and 1980 [s1].
- **Measures**: homicide rates and "11 structural covariates" [s1].
- **Model**: a baseline regression model, then "Principal components analysis" to simplify the covariate space, then re-estimation [s1].
- **Conclusions**: estimates "exhibit instability because of high levels of collinearity among several regressors". After principal components, the inconsistencies "are greatly reduced" [s1].
- **Relevance**: the reason to check VIFs and to avoid entering income, poverty and literacy together without care [not in sources].

## [s31] Nsoesie et al. (2020), Mapping disparities in homicide trends across Brazil: 2000–2014

- **Reference**: Elaine O. Nsoesie et al., Injury Epidemiology [s31].
- **Data and unit**: SIM homicides by municipality, each year from 2000 to 2014; IBGE census population and covariates [s31].
- **Measures**: crude domestic product, urbanization, metro region, border strip and the proportion aged 15–29 [s31].
- **Model**: principal component regression and k-medoids clustering for trends, then a hierarchical Bayesian space-time model in which the annual rate is "modeled as a binomial random variable". It has Besag spatial effects, municipalities nested within states, and is fitted with INLA. Covariates were entered one at a time and in combinations "due to significant correlations between covariates" [s31].
- **Conclusions**: risk is higher in a metro region (RR 1.44, 95% CI 1.38–1.52), in the border strip (1.151), with higher crude domestic product (1.18), and with a higher share aged 15–29 (1.07). The results support dissemination and interiorization [s31].
- **Relevance**: confirms border and youth effects at the municipal level. Its binomial and Bayesian model is outside the apostila [not in sources].

## [s8] Fajnzylber, Lederman & Loayza (2002), Inequality and Violent Crime

- **Reference**: Pablo Fajnzylber, Daniel Lederman, Norman Loayza, The Journal of Law and Economics [s8].
- **Data and unit**: countries, as "nonoverlapping 5‐year averages for 39 countries during 1965–95 for homicides" [s8].
- **Measures**: the Gini index, alternative inequality measures, and homicide and robbery rates [s8].
- **Model**: a panel that controls for "the endogeneity of inequality" and for measurement error through "unobserved country effects and random noise" [s8].
- **Conclusions**: the correlation "reflects causation from inequality to crime rates, even after controlling for other crime determinants" [s8].
- **Relevance**: the main citation for including inequality. Our measure (the mean/median income ratio) is not a Gini index [not in sources].

## [s7] Pratt & Cullen (2005), Assessing Macro-Level Predictors and Theories of Crime: A Meta-Analysis

- **Reference**: Travis C. Pratt, Francis T. Cullen, Crime and Justice [s7].
- **Data and unit**: "over 200 empirical studies" of ecological correlates of crime [s7].
- **Measures**: macro-level predictors, from concentrated disadvantage to criminal-justice variables [s7].
- **Model**: meta-analysis of their relative effects [s7].
- **Conclusions**: "concentrated disadvantage" (e.g., poverty and family disruption) is among the strongest and most stable predictors. Criminal-justice variables except incarceration are among the weakest. Social disorganization and resource/economic deprivation theories receive strong support [s7].
- **Relevance**: the theoretical frame for the article [not in sources].

## [s26] Hsieh & Pugh (1993), Poverty, Income Inequality, and Violent Crime: A Meta-Analysis of Recent Aggregate Data Studies

- **Reference**: Ching-Chi Hsieh, M. D. Pugh, Criminal Justice Review [s26].
- **Data and unit**: "34 aggregate data studies" reporting "76 zero-order correlation coefficients" [s26].
- **Measures**: violent crime against poverty or income inequality [s26].
- **Model**: meta-analysis of correlations [s26].
- **Conclusions**: "all but 2, or 97 percent, were positive". Poverty and inequality "are each associated with violent crime". Homicide and assault "may be more closely associated" [s26].
- **Relevance**: supports expecting positive signs for both poverty and inequality [not in sources].

## [s4] Nivette (2011), Cross-National Predictors of Crime: A Meta-Analysis

- **Reference**: Amy E. Nivette, Homicide Studies [s4].
- **Data and unit**: cross-national studies of homicide [s4].
- **Measures**: predictors including Latin American regional dummies, income inequality, the Decommodification Index, population, democracy and economic development [s4].
- **Model**: meta-analysis [s4].
- **Conclusions**: the strongest mean effects are Latin American dummies, inequality and the Decommodification Index; the weakest are static population indicators, democracy and economic development. Limitations include an "overwhelming reliance on cross-sectional design" [s4].
- **Relevance**: tempers expectations for the population and development variables [not in sources].

## [s2] McCall, Land & Parker (2010), An Empirical Assessment of What We Know About Structural Covariates of Homicide Rates

- **Reference**: Patricia L. McCall, Kenneth C. Land, Karen F. Parker, Homicide Studies [s2].
- **Data and unit**: a review of 20 years of studies, plus "U.S. cities for the years 1970, 1980, 1990, and 2000" [s2].
- **Measures**: the covariates of the Land et al. study [s2].
- **Model**: a systematic empirical assessment; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: "we find support for the claims of invariance established in Land et al." [s2].
- **Relevance**: shows that the structural covariates are stable over time once collinearity is handled [not in sources].

## [s25] Baller et al. (2001), Structural Covariates of U.S. County Homicide Rates: Incorporating Spatial Effects

- **Reference**: Robert D. Baller, Luc Anselin, Steven F. Messner, Glenn Deane, Darnell F. Hawkins, Criminology [s25].
- **Data and unit**: county-level data "for the decennial years in the 1960 to 1990 time period" [s25].
- **Measures**: conventional structural covariates and homicide rates [s25].
- **Model**: regression that explicitly models "spatial effects" [s25].
- **Conclusions**: homicide is "strongly clustered in space", the clustering "cannot be completely explained" by structural similarity, effects differ by region, and the South shows diffusion [s25].
- **Relevance**: justifies checking residuals for spatial correlation and naming spatial models as a limitation [not in sources].

## [s18] Aransiola, Ceccato & Justus (2021), Growth of Lethal Violence in Brazil 2000–2017

- **Reference**: Temidayo James Aransiola, Vania Ceccato, Marcelo Justus, Journal of Contemporary Criminal Justice [s18].
- **Data and unit**: Mortality Information System and Census data, 2000 to 2017 [s18].
- **Measures**: deprivation, ethnic heterogeneity, urbanization, income inequality, unemployment [s18].
- **Model**: "growth models combined with spatial statistics and Geographical Information Systems" [s18].
- **Conclusions**: steady growth in the North and Northeast. Deprivation and urbanization are positive determinants of growth. From 2010 to 2017, inequality's predictive strength fell and unemployment's rose [s18].
- **Relevance**: expect a weaker inequality effect and a stronger unemployment effect in recent data [not in sources].

## [s13] Peres & Nivette (2017), Social disorganization and homicide mortality rate trajectories in Brazil between 1991 and 2010

- **Reference**: Maria Fernanda Tourinho Peres, Amy E. Nivette, Social Science & Medicine [s13].
- **Data and unit**: 4,491 Brazilian municipalities, 1991-2010, using SIM age-standardized homicide rates [s13].
- **Measures**: a 1991 composite social disorganization index [s13].
- **Model**: group-based trajectory models, then logistic regression on the index [s13].
- **Conclusions**: "We found that SD is associated with an ascending homicide trajectory", driven by "a small proportion of municipalities in the country" [s13].
- **Relevance**: theory for the disorganization variables (urbanization, migration). The saved text gives no index components [not in sources].

## [s10] Wanzinack, Signorelli & Reis (2018), Homicides and socio-environmental determinants of health in Brazil: a systematic literature review

- **Reference**: Clóvis Wanzinack, Marcos Signorelli, Clóvis Reis, Cadernos de Saúde Pública [s10].
- **Data and unit**: 60 studies published between 2002 and 2017 [s10].
- **Measures**: determinants grouped as territory, gender, age, inequalities, development, education, work and drugs [s10].
- **Model**: a systematic review under PRISMA guidelines, with narrative synthesis [s10].
- **Conclusions**: homicide is associated with low education, high social inequality, unemployment and drug trafficking. "Education seems to be a protective factor for homicide" [s10].
- **Relevance**: a single citation for the Brazilian evidence on education and labour variables [not in sources].

## [s11] Mello & Schneider (2007), Age Structure Explaining a Large Shift in Homicides: The Case of the State of São Paulo

- **Reference**: João Manoel Pinho de Mello, Alexandre Schneider, PUC-Rio discussion paper (RePEc) [s11].
- **Data and unit**: the state of São Paulo, "at the statewide and at city levels" [s11].
- **Measures**: "the proportion of males on the 15-25 age bracket" and homicides [s11].
- **Model**: co-movement analysis with a causal argument; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: "a 1% increase in the proportion of 15-to-24-year-old males causes a 4.5% increase in homicides" [s11].
- **Relevance**: the Brazilian anchor for the share of young men [not in sources].

## [s14] Levitt (1999), The Limited Role of Changing Age Structure in Explaining Aggregate Crime Rates

- **Reference**: Steven D. Levitt, Criminology [s14].
- **Data and unit**: aggregate crime rates, including projections "between 1995 and 2010" [s14].
- **Measures**: age structure and crime rates [s14].
- **Model**: not stated in the saved text [not in sources].
- **Conclusions**: the baby boom "shifted crime rates by no more than 1 % per year" [s14].
- **Relevance**: the counterweight on age structure [not in sources].

## [s15] Becker & Kassouf (2017), Uma análise do efeito dos gastos públicos em educação sobre a criminalidade no Brasil

- **Reference**: Kalinca Léia Becker, Ana Lúcia Kassouf, Economia e Sociedade [s15].
- **Data and unit**: "dados socioeconômicos dos estados brasileiros" [s15].
- **Measures**: education spending per capita, lagged, and the homicide rate [s15].
- **Model**: "modelo de painel dinâmico (GMM-SYS)" [s15].
- **Conclusions**: "se os gastos com educação aumentarem 10%, a taxa de homicídios diminuiria 1% no período seguinte" [s15].
- **Relevance**: supports a protective sign for education [not in sources].

## [s21] Cerqueira & de Mello (2013), Evaluating a National Anti-Firearm Law and Estimating the Causal Effect of Guns on Crime

- **Reference**: Daniel Cerqueira, João de Mello, PUC-Rio discussion paper [s21].
- **Data and unit**: Brazil's 2003 national law; the lives-saved estimate covers cities with more than 50,000 inhabitants in the state of São Paulo [s21].
- **Measures**: homicides, firearms prevalence and property crime [s21].
- **Model**: an impact evaluation of the December 2003 law, identified by baseline gun prevalence [s21].
- **Conclusions**: the law "saved between 2,000 and 2,750 lives from 2004 through 2007" [s21].
- **Relevance**: firearms are an omitted variable in our data [not in sources].

## [s19] Biderman et al. (2019), Pax Monopolista and Crime: The Case of the Emergence of the Primeiro Comando da Capital in São Paulo

- **Reference**: Ciro Biderman, João Manoel Pinho de Mello, Renato Sérgio de Lima, Alexandre Schneider, Journal of Quantitative Criminology [s19].
- **Data and unit**: favelas in the city of São Paulo, by timing of PCC entry [s19].
- **Measures**: violent crime and property crime [s19].
- **Model**: difference-in-differences [s19].
- **Conclusions**: "PCC presence is associated with an 11% reduction in violent crime" in 2005–2009; there was no discernible impact on property crime [s19].
- **Relevance**: faction effects are real but unmeasured in our data [not in sources].

## [s6] Justus, Cerqueira, Kahn & Carvalho (2018), The "São Paulo Mystery": The role of the criminal organization PCC in reducing the homicide in 2000s

- **Reference**: Marcelo Justus, Daniel Cerqueira, Túlio Kahn, Gustavo Carvalho, EconomiA [s6].
- **Data and unit**: São Paulo state in the 2000s [s6].
- **Measures**: socioeconomic and demographic measures, firearms and law enforcement [s6].
- **Model**: "a first-difference fixed effects model with a spatial structure" [s6].
- **Conclusions**: "Our results do not support the PCC hypothesis" [s6].
- **Relevance**: the state-level counterweight to [s19] [not in sources].

## [s20] Goertzel & Kahn (2009), The Great São Paulo Homicide Drop

- **Reference**: Ted Goertzel, Túlio Kahn, Homicide Studies [s20].
- **Data and unit**: the city and state of São Paulo, 2001 to 2007, from "a number of independent data sources" [s20].
- **Measures**: homicide rates [s20].
- **Model**: descriptive comparison; no estimator is stated in the saved text [not in sources].
- **Conclusions**: the decline "may be attributed to more effective policing methods including the better enforcement of strict gun-control legislation" [s20].
- **Relevance**: the policing explanation, which our data cannot measure [not in sources].

## [s5] Feltrán et al. (2022), Variations in Homicide Rates in Brazil: An Explanation Centred on Criminal Group Conflicts

- **Reference**: Gabriel Feltrán et al., Dilemas [s5].
- **Data and unit**: ethnographic experience in four capitals (São Paulo, Porto Alegre, São Luís and Maceió) and homicide data by victim profile [s5].
- **Measures**: homicide rates by profile and histories of local faction conflicts [s5].
- **Model**: qualitative comparison with historical synopses [s5].
- **Conclusions**: homicide rates "oscillate based on changes in conflicts between factions at the local level" [s5].
- **Relevance**: the main omitted mechanism in a Censo-based model [not in sources].

## [s22] Pereira, Pucci & Soares (2024), Landing on Water: Air Interdiction, Drug-Trafficking Displacement, and Violence in the Brazilian Amazon

- **Reference**: Leila Pereira, Rafael Pucci, Rodrigo Soares, SSRN/IZA working paper [s22].
- **Data and unit**: "data on cocaine production, homicides, and the network of rivers in the Amazon" [s22].
- **Measures**: homicides in municipalities along river routes [s22].
- **Model**: comparison before and after the policy; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: violence increased "in municipalities along river routes originating from Andean producing countries" [s22].
- **Relevance**: a mechanism for the Amazônia Legal and border indicators [not in sources].

## [s29] Eleuterio-da-Rocha et al. (2026), Legal gun ownership and carrying are not associated with homicides in Brazil

- **Reference**: Joe Eleuterio-da-Rocha et al., International Journal of Comparative and Applied Criminal Justice [s29].
- **Data and unit**: state-level longitudinal data, using "official data on firearm possession and carrying" [s29].
- **Measures**: legal gun ownership and carrying, and the number of homicides [s29].
- **Model**: "Bayesian multilevel models with state-level variation explicitly modelled" [s29].
- **Conclusions**: legal gun ownership "is unlikely to be a significant driver of the number of homicides". State "criminal justice policies and institutional contexts may play a more decisive role" [s29].
- **Relevance**: supports state indicators as a stand-in for institutions [not in sources].

## [s28] Murray, Cerqueira & Kahn (2013), Crime and violence in Brazil: Systematic review of time trends, prevalence rates and risk factors

- **Reference**: Joseph Murray, Daniel Cerqueira, Túlio Kahn, Aggression and Violent Behavior [s28].
- **Data and unit**: a systematic review that identified 10 studies on self-reported offending and 9 on risk factors. It reports 1 million homicides in Brazil between 1980 and 2010 [s28].
- **Model**: systematic review [s28].
- **Conclusions**: homicide increases "followed rises in inequality, more young men in the population, greater availability of firearms, and increased drug use". Disarmament legislation "may have helped" [s28].
- **Relevance**: a general Brazilian background citation [not in sources].

## [s17] Ipea/FBSP (2025), Atlas da Violência 2025

- **Reference**: D. Cerqueira, S. Bueno (coords.), Ipea and FBSP [s17].
- **Data and unit**: homicide rates by state (UF), from 2013 to 2023 [s17].
- **Measures**: homicídios registrados per 100 mil habitantes [s17].
- **Model**: descriptive [s17].
- **Conclusions**: in 2023, rates ranged from 6,4 in São Paulo to 57,4 in Amapá, against a national rate of 21,2. Factors that "potencialmente" contributed to the decline were population ageing, "o armistício na grande guerra do narcotráfico entre as duas maiores fações criminais" and better security policies. The diffusion of guns after 2019 slowed the decline [s17].
- **Relevance**: the official context for 2021–2023 [not in sources].

## [s23] Ipea/FBSP (2024), Atlas da Violência 2024: Retrato dos Municípios Brasileiros

- **Reference**: IPEA and FBSP [s23].
- **Data and unit**: Brazilian municipalities in 2022 [s23].
- **Measures**: 46.409 homicídios registrados plus 5.982 homicídios ocultos, from deaths of undetermined intent [s23].
- **Model**: descriptive [s23].
- **Conclusions**: the national rate goes from 21,7 registered to 24,5 estimated. Small cities average 21,7, against 26,2 for medium and 26,4 for large ones. "A métrica de taxa por cem mil habitantes não é recomendável para municípios pequenos" [s23].
- **Relevance**: supports the population cut-off and the undetermined-intent control [not in sources].

## [s32] Carvalho et al. (2012), Taxas bayesianas para o mapeamento de homicídios nos municípios brasileiros

- **Reference**: Alexandre X. Y. de Carvalho et al., Cadernos de Saúde Pública [s32].
- **Data and unit**: homicides in "5.566 municípios brasileiros, no ano de 2008", from SIM-DATASUS [s32].
- **Measures**: the homicide rate under different estimators [s32].
- **Model**: the crude rate against empirical Bayes rates (global and spatial) and Clayton & Kaldor Bayesian rates [s32].
- **Conclusions**: the crude rate flagged one municipality at 211,10, and it is "a única estimativa em que o coeficiente de variação é maior do que 1,0". Corrections matter "especially for small municipalities" [s32].
- **Relevance**: justifies the cut-off and the averaging. Empirical Bayes is outside the apostila [not in sources].

## [s9] Resende & Andrade (2011), Crime social, castigo social: desigualdade de renda e taxas de criminalidade nos grandes municípios brasileiros

- **Reference**: João Paulo de Resende, Mônica Viégas Andrade, Estudos Econômicos [s9].
- **Data and unit**: police reports (boletins de ocorrência) from SENASP, for "municípios brasileiros com população superior a cem mil habitantes" [s9].
- **Measures**: income inequality and rates of different crime types [s9].
- **Model**: not stated in the saved text [not in sources].
- **Conclusions**: inequality's effect is "positiva e robusta, principalmente para os crimes contra o patrimônio" [s9].
- **Relevance**: suggests inequality matters less for homicide than for property crime [not in sources].

## [s27] Figueiredo et al. (2024), Dinâmicas da violência na Região Norte do Brasil

- **Reference**: Ana Clara Figueiredo et al., Ipea book chapter [s27].
- **Data and unit**: Brazilian homicide rates over four decades, by region [s27].
- **Measures**: homicide rates [s27].
- **Model**: descriptive and interpretive [s27].
- **Conclusions**: the rate peaked in 2017 at 30,9. The concentration shifted from the Southeast to the Northeast and North "desde meados da década de 2000", with an "interiorização da violência" [s27].
- **Relevance**: context for the North and Northeast and the Amazon indicators [not in sources].

## [s30] FBSP (2025), Cartografias da Violência na Amazônia 2025

- **Reference**: Fórum Brasileiro de Segurança Pública, executive summary [s30].
- **Data and unit**: the Legal Amazon [s30].
- **Model**: descriptive report [s30].
- **Conclusions**: the CV and the PCC "se articulam com facções regionais, ora cooperando, ora competindo por rotas, mercados e territórios". Lethal rates remain "muito acima da média nacional" [s30].
- **Relevance**: context for the Amazônia Legal indicator [not in sources].

## [s16] Cerqueira & Lobão (2004), Determinantes da criminalidade: arcabouços teóricos e resultados empíricos

- **Reference**: Daniel Cerqueira, Waldir Lobão, Dados [s16].
- **Data and unit**: a review of theoretical frameworks and their link to quantitative empirical work [s16].
- **Model**: literature review [s16].
- **Conclusions**: the saved abstract only describes the review's scope [s16].
- **Relevance**: a Portuguese-language theory review for the article's introduction [not in sources].

## [s44] Merton (1938), Social Structure and Anomie

- **Reference**: Robert K. Merton, American Sociological Review.
- **Data and unit**: a conceptual scheme; the saved text shows no data [s44].
- **Measures**: two elements of social structure, "culturally defined goals, purposes, and interests" and the rules that define "the acceptable modes of achieving these goals" [s44].
- **Model**: a conceptual scheme for "socio-cultural sources of deviate behavior" [s44].
- **Conclusions**: some social structures "exert a definite pressure upon certain persons in the society to engage in nonconformist rather than conformist conduct". This happens when goals are stressed with "relatively slight concern with the institutionally appropriate modes of attaining these goals" [s44].
- **Relevance**: the root of strain and relative-deprivation theory. Where a municipality shows the goals of consumption but blocks the means to reach them, more deviance is expected [not in sources].

## [s34] Blau & Blau (1982), The Cost of Inequality: Metropolitan Structure and Violent Crime

- **Reference**: Judith R. Blau, Peter M. Blau, American Sociological Review.
- **Data and unit**: the 125 largest American metropolitan areas (SMSAs) [s34].
- **Measures**: rates of criminal violence, socioeconomic inequality, poverty and Southern location [s34].
- **Inequality measure (secondary sources, unverified)**: a Gini index of family income, plus a between-race income gap. The paper's methods were not read [not in sources].
- **Model**: not stated in the saved text [not in sources].
- **Conclusions**: "economic inequality generally, increases rates of criminal violence, but once economic inequalities are controlled poverty no longer influences these rates" [s34].
- **Relevance**: the founding relative-deprivation test, with the opposite conclusion to [s3]. Our partial F tests take up the same contest [not in sources].

## [s35] Sampson & Groves (1989), Community Structure and Crime: Testing Social-Disorganization Theory

- **Reference**: Robert J. Sampson, W. Byron Groves, American Journal of Sociology.
- **Data and unit**: 238 localities in Great Britain from a 1982 national survey of 10,905 residents, replicated on 300 localities in 1984 [s35].
- **Measures**: low economic status, ethnic heterogeneity, residential mobility and family disruption; social organization measured by "local friendship networks, control of street-corner teenage peer groups, and prevalence of organizational participation" [s35].
- **Model**: a community-level model in which structure works through social disorganization; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: "between-community variations in social disorganization transmit much of the effect of community structural characteristics on rates of both criminal victimization and criminal offending" [s35].
- **Relevance**: the theory behind the urbanization, migration and density controls. Its Brazilian application is [s13] [not in sources].

## [s37] Becker (1968), Crime and Punishment: An Economic Approach

- **Reference**: Gary S. Becker, Journal of Political Economy.
- **Data and unit**: a formal choice model; the saved text shows no data [s37].
- **Measures**: the probability of conviction, the punishment, and "the income available to him in legal and other illegal activities" [s37].
- **Model**: a choice model in which "a person commits an offense if the expected utility to him exceeds the utility he could get by using his time and other resources at other activities" [s37].
- **Conclusions**: some people become criminals "not because their basic motivation differs from that of other persons, but because their benefits and costs differ" [s37].
- **Relevance**: in the economic view, income works through opportunity cost: more legal income lowers crime, and more wealth around offers more targets. This gives a mechanism for non-linear income effects [not in sources].

## [s36] Messner & Rosenfeld (1997), Political Restraint of the Market and Levels of Criminal Homicide

- **Reference**: Steven F. Messner, Richard Rosenfeld, Social Forces.
- **Data and unit**: national homicide rates in a cross-national analysis [s36].
- **Measures**: the "decommodification of labor", from welfare expenditures [s36].
- **Model**: a cross-national multivariate analysis; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: homicide is expected to "vary inversely with the "decommodification of labor."" The results "support our hypothesis and lend credibility to the institutional-anomie perspective" [s36].
- **Relevance**: institutional anomie is the macro version of Merton's strain theory. Here social protection softens the market's pressure [not in sources].

## [s33] Kelly (2000), Inequality and Crime

- **Reference**: Morgan Kelly, The Review of Economics and Statistics.
- **Data and unit**: urban counties in the United States [s33].
- **Measures**: inequality, poverty, police activity, and property and violent crime [s33].
- **Model**: regressions that test the economic, strain and social-disorganization theories against each other; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: "Inequality has no effect on property crime but a strong and robust impact on violent crime, with an elasticity above 0.5". Violent crime "is better explained by strain and social disorganization theories" [s33].
- **Relevance**: the clearest test that inequality, through strain, explains violent crime while poverty does not. It supports our focus on inequality for homicide [not in sources].

## [s38] Messner (1982), Societal Development, Social Equality, and Homicide: A Cross-National Test of a Durkheimian Model

- **Reference**: Steven F. Messner, Social Forces.
- **Data and unit**: a cross-sectional analysis of 50 nations [s38].
- **Measures**: development, moral individualism, equality and homicide [s38].
- **Model**: a cross-sectional analysis of a Durkheimian model; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: development is predicted to have "no significant zero-order relationship" with homicide, and equality "a negative partial effect". The results "provide partial support for the theory" [s38].
- **Relevance**: the modernization debate: development changes violence through equality, not directly [not in sources].

## [s39] Buonanno, Fergusson & Vargas (2017), The Crime Kuznets Curve

- **Reference**: Paolo Buonanno, Leopoldo Fergusson, Juan F. Vargas, Journal of Quantitative Criminology.
- **Data and unit**: not stated in the saved text [not in sources].
- **Measures**: income levels and crime by type [s39].
- **Model**: a test of an inverted-U relation between income and crime; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: "As income levels have risen, crime has followed an inverted U-shaped pattern". The curve "is not explained by income inequality" and holds "for property crime and for some categories of violent crime" [s39].
- **Relevance**: the most direct precedent for H1, our inverted-U shape of income, though not specifically for homicide [not in sources].

## [s40] Ouimet (2012), A World of Homicides

- **Reference**: Marc Ouimet, Homicide Studies.
- **Data and unit**: 165 countries in 2010 [s40].
- **Measures**: GNI, the Gini index, poverty (excess infant mortality) and homicide [s40].
- **Model**: regression analyses with subsamples by level of human development [s40].
- **Conclusions**: development, inequality and poverty all predict homicide across all countries. But "income inequality, not economic development or poverty, predicts homicide for countries with a medium level of human development" [s40].
- **Relevance**: direct support for H2, inequality mattering most at intermediate development [not in sources].

## [s41] Aransiola, Justus et al. (2024), Economic growth, income inequality and lethal violence in developed countries

- **Reference**: Temidayo James Aransiola, Marcelo Justus et al., EconomiA.
- **Data and unit**: OECD panel data spanning 2000 to 2018 [s41].
- **Measures**: GDP, income inequality and homicide rates [s41].
- **Model**: "dynamic panel GMM models" with a GDP × inequality interaction [s41].
- **Conclusions**: "a nonlinear relationship between GDP and homicide rates", and "income inequality conditions the effect of GDP on homicide rates" [s41].
- **Relevance**: the closest precedent for both H1 and H2, an income non-linearity plus an income × inequality interaction, though in rich countries [not in sources].

## [s42] Wanzinack, Signorelli & Reis (2022), Violence and social determinants of health in Brazil

- **Reference**: Clóvis Wanzinack, Marcos Signorelli, Clóvis Reis, Cadernos de Saúde Pública.
- **Data and unit**: a retrospective ecological study of 5,570 Brazilian municipalities, with SIM homicides averaged from 2005 to 2015 [s42].
- **Measures**: HDI-M, the Gini index, urbanization and population (log 10) [s42].
- **Model**: relative effects (%) on homicide risk; the estimator is not stated in the saved text [not in sources].
- **Conclusions**: higher risk with population (80.8%, 95%CI: 73.0; 88.8), urbanization (8%, 95%CI: 6.7; 9.2) and a higher Gini index (6%, 95%CI: 2.6; 9.5). The relation with HDI-M is inverse (-17.1%, 95%CI: -21.4; -12.6) [s42].
- **Relevance**: the most recent all-municipality study with the Gini. It tests no non-linearity or interaction, which is our contribution [not in sources].

## [s43] Neumayer (2003), Good Policy Can Lower Violent Crime

- **Reference**: Eric Neumayer, Journal of Peace Research.
- **Data and unit**: a cross-national panel of up to 117 countries, 1980–97 [s43].
- **Measures**: income, growth, inequality, democracy, human rights and homicide [s43].
- **Model**: "a fixed-effects estimator with fully robust standard errors", with random effects as sensitivity [s43].
- **Conclusions**: higher income and growth go with lower homicide. "the positive effect of income inequality on homicide rates found in many studies might be spurious" [s43].
- **Relevance**: the main critique: with fixed effects, the inequality effect may vanish. Our state indicators play a similar role [not in sources].
