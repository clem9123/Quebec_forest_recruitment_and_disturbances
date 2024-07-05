# Quebec_forest_recruitment_and_disturbances

## Context and summary of the study

*Context:* 

Climate change poses challenges to tree populations, leading to responses such as adaptation, migration, and extinction. In the Quebec ecotone, transition zone between temperate and boreal forest, multiple species reach their northern distribution limits and are predicted to undergo important northern migration. Understanding tree recruitment dynamic, often left out in forest models, could help anticipate distribution range shifts in the ecotone and adapt forest management.

*Method:* 

We examined the impact of disturbances on saplings (diameters [1;3] cm) recruitment using a Bayesian hurdle model with presence and abundance data from 1970 to 2021.

*Results:*

We found a significant range shifts for temperate species. Recruitment was primarily influenced by the presence of conspecific adults. Disturbances had diverse effects, generally benefiting Acer rubrum (red maple), a generalist and opportunistic temperate species. While clearcut and fire had a positive mid-term (10-50 years) impact on pioneer species, partial cut favored temperate species recruitment to a greater extent.

*Conclusion:*

Anthropogenic disturbances could promote certain species and facilitate latitudinal shift.  However, the importance of conspecific adult presence suggests that additional measures, such as assisted migration through plantation, may be necessary to ensure the northward shift of species distribution.



## Structure of this repository 

This repository is structured as a R package and can be installed as such. 

```R
install.packages("remotes")
remotes::install_github("LaboBrice/Quebec_forest_recruitment_and_disturbances")
```

Once installed, functions and data can be used as follows:

```R
library(QuebecSaplingsRecruitment)
```


### Data

Raw data are available on the "Données Québec" website at the following URL: https://www.donneesquebec.ca/recherche/dataset/placettes-echantillons-permanentes-1970-a-aujourd-hui.

```{r}
download.file("https://diffusion.mffp.gouv.qc.ca/Diffusion/DonneeGratuite/Foret/DONNEES_FOR_ECO_SUD/Placettes_permanentes/PEP_GPKG.zip", destfile = "raw_data/PEP.zip")
```

See scripts `inst/1_Make_data` to see all the steps required to obtain the data used in this analysis (NB: script 1 to 8 must be run in order), the resulting output data frame is `data/full_data.rda` and is an object of the package. 


```R
library(QuebecSaplingsRecruitment)
head(full_data[, 1:10])
       id_pe    id_pe_mes no_mes year_measured essence all_cl sp_code tree_nb_sp tree_ba_sp  tree_ba
1 0119600201 011960020101      1          2001     BOP      0  BETPAP         18    2254.99 13858.39
2 0119600201 011960020101      1          2001     BOP      0  BETPAP         18    2254.99 13858.39
3 0119600201 011960020101      1          2001     BOP      0  BETPAP         18    2254.99 13858.39
4 0119600201 011960020101      1          2001     BOJ      0  BETALL          6     787.87 13858.39
5 0119600201 011960020101      1          2001     EPB      0  PICGLA          5     776.83 13858.39
6 0119600201 011960020101      1          2001     EPB      0  PICGLA          5     776.83 13858.39
```

### Models 

Models were built as standalone JAGS files stored in `inst/jags_models` and models
were run using the R package [`R2jags`](https://CRAN.R-project.org/package=R2jags),
see `run_jags_model()` in `R/run_model.R`. For instance: 

```R
run_jags_model("ACERUB", "model_time_class2_without_ba.bugs",
    n.chains = 3, n.iter = 100, devel = TRUE
)
```






## OLDER -- Repo and analyse structure

### Data

Initial data are from the Minister : https://www.donneesquebec.ca/recherche/dataset/placettes-echantillons-permanentes-1970-a-aujourd-hui

```{r}
download.file("https://diffusion.mffp.gouv.qc.ca/Diffusion/DonneeGratuite/Foret/DONNEES_FOR_ECO_SUD/Placettes_permanentes/PEP_GPKG.zip", destfile = "raw_data/PEP.zip")
```

See `inst/1_Make_data/tree_pep.R`.Then all selection and modification on this data are made with the files from
`inst/1_Make_data` (1 to 8 have to bee run in order), the output data frame is `data/full_data.ata` and is the one I used for all following analyses

It is not necessary to run all the code to make the data, you can just use the output `data/full_data.RData` and start with the analyses part.

#### Code in data

Table correspondance soil caracteristics/number :

|Code | Soil caracteristics |
|-----|----------|
| 0 | texture variée et drainage de xérique à hydrique |
| 1 | texture grossière et de drainage xérique ou mésique |
| 2 | texture moyenne et de drainage mésique |
| 3 | texture fine et de drainage mésique |
| 4 | texture grossière et de drainage subhydrique |
| 5 | texture moyenne et de drainage subhydrique |
| 6 | texture fine et de drainage subhydrique |
| 7 | drainage hydrique, ombrotrophe |
| 8 | drainage hydrique, minérotrophe |


### Analyses

#### 1. Analyses of the data : `R/2_Data_analysis`

File :
- `Data_analysis.Rmd` : Analyses of the data and make some figures and tables. Figures for the article made in this document and can be found in `/figures`.

Figures made :
- Map of the study area (Figure 1)
- number of disturbances by types and distribution of time since disturbance for each one
- PCA on soil and climate
- Link between basal area and disturbances
- Map of the presence absence of each species at the first and last inventory (Figure 2)
- link between species presence and climate (CMI and temperature)

#### 2. Analyses of space and time : `R/3_Space_time_model`

Code to make the space time frequentist model with glmmTMB (https://github.com/glmmTMB/glmmTMB).
Figure in my article in this part are made in this document and can be found in /figures.

#### 3. Analyses of disturbance effect : `R/4_Disturbance_model`

##### a. Choice of parameters

Covariable selection for subsequent bayesian model with buildmer (https://github.com/cvoeten/buildmer). Thanks to Cesko Voeten for this package.
Just ran different hurdle models for all species and step them to select important covariables.
Also a little bit of co-linearity analysis between variables.

##### b. Bayesian model

Bayesian model with JAGS (https://mcmc-jags.sourceforge.io/). Thanks to Martyn Plummer for this package.

With :
- `Model.txt` : The model specification
- `function_run.R` : Create the function to run the model with jags.parallel
(Make the specific data for the model)
- `Run.R` : Run the model for all the species in parallel **!!! Uses a lot of core (30) so be careful to have enough on your system or decrease the number in :

```{r}
cl <- makeCluster(30)
```

Analyse of the model output are made in `Analyse.Rmd` and uses `function_analyses.R` to make the figures and tables. Figures in my article in this part are made in this document and can be found in `/figures`.

### Output

Output of the 8 individual model for each species was not uploaded here because of weight but you can find some of the data I extracted from them in `/output`

They are data frame with the parameters and the 95% credible interval for each species
- `all_param.rds` : data frame with all covariates parameters (presence of conspecific adult individuals, basal area, soil, climate...)
- `quadratic.rds` : data frame with the quadratic effect of cmi and temperature
- `disturbance_pa.rds` and `disturbance_nb.rds`: data frame with the effect of each disturbance after 10, 20 and 30 years on presence and abundance respectively

`Pre-article.Rmd` allows you to make the figure for these data frames

# A faire :

IMPORTANT :

- [ ] refaire la map de l'intro (study area)
- [x] Refaire tourner les modèles avec 
- [x] et sans BA
- [x] (+ tableau de comparaison déviance + BIC)
- [x] Faire des output utilisable : (tableau plus cours des résutats pour pouvoir les uploader sur Github dans output)
- [x] Relire le README
- [x] Relire le code
- [ ] Relire le rapport
- [ ] download code from server
- [ ] Make short model to see if eventually i can upload them to github

ANECDOTIQUE :

- [ ] Simplifier les bordures de la carte (st simplify)
- [ ] Virer result.RDS
- [ ] learn to do less crappy Rmarkdown doc


# DIC with and without BA

Best one is with min DIC

| species | DIC with BA | DIC without BA | Best model |
|---------|-------------|----------------| ---------- |
| ABIBAL  | 303503.63   | 303172.48      | without BA |
| ACERUB  | 118383.95   | 118372.79      | without BA |
| BETALL  | 86056.14    | 86067.24       | with BA    |
| ACESAC  | 96443.36    | 96443.91       | same       |
| PICMAR  | 180206.13   | 180473.58      | with BA    |
| PICGLA  | 99042.42    | 99035.78       | without BA |
| BETPAP  | 171853.90   | 171273.91      | without BA |
| POPTRE  | 108596.19   | 108222.15      | without BA |

# deviance with and without BA

| species | deviance with BA | deviance without BA | Best model |
|---------|------------------|----------------------| ---------- |
| ABIBAL  | 303420.43        | 303089.63            | without BA |
| ACERUB  | 118302.98        | 118291.10            | without BA |
| BETALL  | 85979.62         | 85986.92             | with BA    |
| ACESAC  | 96368.04         | 96368.65             | same       |
| PICMAR  | 180126.44        | 180389.62            | with BA    |
| PICGLA  | 98956.28         | 98950.17             | without BA |
| BETPAP  | 171770.47        | 171188.79            | without BA |
| POPTRE  | 108510.65        | 108139.57            | without BA |
