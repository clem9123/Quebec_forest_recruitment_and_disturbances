# Quebec_forest_recruitment_and_disturbances
 Repo for all the code of my M2 intership at the IRBV with Marie-Hélène Brice

## Context and summary of the study

*Context:* 

Climate change poses challenges to tree populations, leading to responses such as adaptation, migration, and extinction. In the Quebec ecotone, transition zone between temperate and boreal forest, multiple species reach their northern distribution limits and are predicted to undergo important northern migration. Understanding tree recruitment dynamic, often left out in forest models, could help anticipate distribution range shifts in the ecotone and adapt forest management.

*Method:* 

We examined the impact of disturbances on saplings (diameters [1;3] cm) recruitment using a Bayesian hurdle model with presence and abundance data from 1970 to 2021.

*Results:*

We found a significant range shifts for temperate species. Recruitment was primarily influenced by the presence of conspecific adults. Disturbances had diverse effects, generally benefiting Acer rubrum (red maple), a generalist and opportunistic temperate species. While clearcut and fire had a positive mid-term (10-50 years) impact on pioneer species, partial cut favored temperate species recruitment to a greater extent.

*Conclusion:*

Anthropogenic disturbances could promote certain species and facilitate latitudinal shift.  However, the importance of conspecific adult presence suggests that additional measures, such as assisted migration through plantation, may be necessary to ensure the northward shift of species distribution.


## Repo and analyse structure

### Data

Initial data are from the Minister : https://www.donneesquebec.ca/recherche/dataset/placettes-echantillons-permanentes-1970-a-aujourd-hui

```{r}
download.file("https://diffusion.mffp.gouv.qc.ca/Diffusion/DonneeGratuite/Foret/DONNEES_FOR_ECO_SUD/Placettes_permanentes/PEP_GPKG.zip", destfile = "raw_data/PEP.zip")
```

See beginning or `R/1_Make_data/tree_pep.R`

Then all selection and modification on this data are made with the files from
`R/1_Make_data` (have to bee run in order), the output dataframe is `data/full_data.RDS` and is the one I used for all following analyses

#### Code in data

Table correspondance soil numberc :

|Code | Soil caracteristics |
|-----|----------|
| 1 | de texture grossière et de drainage xérique ou mésique |
| 2 | 
| 3 | 
| 4 | 
| 5 | 
| 6 | 



### Analyses

#### 1. Analyses of the data : `R/2_Data_analysis`

#### 2. Analyses of space and time : `R/3_Space_time_model`

Code to make the space time frequentist model with glmmTMB (https://github.com/glmmTMB/glmmTMB).
Figure in my article in this part are made in this document and can be found in /figures.

#### 3. Analyses of disturbance effect : `R/4_Disturbance_model`

##### a. Choice of parameters

Covariable selection for subsequent bayesian model with buildmer (https://github.com/cvoeten/buildmer). Thanks to Cesko Voeten for this package.

##### b. Bayesian model

Bayesian model with JAGS (https://mcmc-jags.sourceforge.io/). Thanks to Martyn Plummer for this package.

With :
- `Model.txt` : The model specification
- `function_run.R` : Create the function to run the model with jags.parallel
(Make the specific data for the model)
- `Run.R` : Run the model for all the sppecies in parallel **!!! Uses a lot of core (30) so be careful to have enough on your system or decrease the number in

```{r}
cl <- makeCluster(30)
```

Analyse of the model output are made in `Analyse.Rmd` and uses `function_analyses.R` to make the figures and tables. Figures in my article in this part are made in this document and can be found in `/figures`.

### Output

Output of the 8 individual model for each species was not uploaded here because of weight but you can find some of the data I extracted from them in `/output` :

- 
- 


# A faire :

- [ ] CONVERGENCE






- [x] Telecherger les models finaux sur ripley
- [x] Mettre les figures dans un dossier `figures`
- [ ] Faire les tableaux de corrspondances chiffre/signification pour les variables qualitatives (sol en particulier)
- [ ] Plot les sorties du sol
- [x] Rédiger le README
- [ ] Faire des output utilisable : (tableau plus cours des résutats poir pouvoir les uploader sur Github dans output) : les sorties des paramères (mean, min and mean)
- [ ] Figure parametre : espèce en italique + nom en anglais (eventuellement density plot)
- [x] Check correlation entre soil, ph et epmatorg


Simplifier les bordures de la carte (st simplify)

# Question

- problème de convergence de l'intercept
- Quel visuel pour les sorties ?
- What to do in the text ? Ref, ecrire priors

# Sub-model BA

| with BA sub model  |  without BA sub model |
|--------------------|-----------------------|
|        179325.72   |             180250.71 |
|         95652.49   |              95603.13 |
|         79111.98   |              79202.24 |
|         85415.10   |              85466.13 |
|        125876.68   |             126024.51 |
|         84753.54   |              84786.29 |
|        117718.97   |             117585.83 |
|         87105.70   |              86826.04 |
|--------------------|-----------------------|