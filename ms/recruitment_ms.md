---
documentclass: article
font: 12pt
papersize: a4paper
geometry: margin=1in
bibliography: [/Users/mariehbrice/Documents/GitHub/references.bib]
numbersections: true
header-includes:
  - \usepackage{setspace}
  - \doublespacing
  - \usepackage{lineno}
  - \linenumbers
  - \usepackage{float}
  - \floatplacement{figure}{H}
  - \usepackage{caption}
  - \renewcommand{\figurename}{\bfseries Figure}
---

# Effect of anthropogenic and natural disturbances on tree regeneration at the boreal-temperate ecotone: catalyst or impediment to northward migration?  {-} <!--[qqch du genre]>

Clémentine de Montgolfier^1^, Marie-Hélène Brice*^1,2^, 
<!--Marie-Josée Fortin, Pierre Legendre-->

## Institutional affiliations {-}


1. Jardin botanique de Montréal, 4101 Sherbrooke Est, Montréal, QC, Canada H1X 2B2 
2. Institut de recherche en biologie végétale, Département de sciences biologiques, Université de Montréal, 4101 Sherbrooke Est, Montréal, QC, Canada H1X 2B2 



## Contact Information {-}

Marie-Hélène Brice

- email: marie-helene.brice@umontreal.ca

\pagebreak


# Graphical abstract (optional) 

# Highlights 

<!--Highlights are mandatory for this journal as they help increase the discoverability of your article via search engines. 
short collection of bullet points that capture the novel results of your research as well as new methods that were used during the study
Highlights should be submitted in a separate editable file in the online submission system. Please use 'Highlights' in the file name and include 3 to 5 bullet points (maximum 85 characters, including spaces, per bullet point).-->

# Abstract (max 400 mots) 


Context. Tree recruitment is a critical step to initiate species range shifts in forest under climate change. While non-climatic factors may slow down sapling establishment, canopy disturbances may promote episodic recruitment pulses of migrating species. Yet, our understanding of how different factors control tree recruitment dynamics at range margins remains limited.

Method. We analyzed forest inventory data sampled from 1970 to 2021 in Quebec, Canada, to study the effect of different disturbances on the recruitment dynamics of saplings (1 to 3 cm in diameter). For each of the most abundant species in the boreal-temperate ecotone, we fitted a Bayesian hurdle model on presence and abundance data to quantify the role of climate, disturbances, and stand characteristics.

Results. Significant shifts in the distribution of temperate species northwards were observed. Recruitment was primarily influenced by the presence of conspecific adults, while disturbances had diverse effects. Clearcut and fires had a short-term positive impact on pioneer species, whereas partial cuts promoted the recruitment of temperate species. Red maple (*Acer rubrum*), a generalist and opportunistic temperate species, particularly benefited from all types of disturbances.

Conclusion. Temporal patterns of sapling recruitment provided an early signal of northward migrations of temperate tree species and indicated that important compositional changes are underway. However, disturbances can influence the magnitude and direction of these range shifts and should thus be considered in projections of future species distribution. While partial cuts favors the recruitment of temperate species at their northern limit, fires, limited dispersal, and edaphic conditions can greatly reduce their potential migrations.

# Keywords 

Climate change, Disturbances, Harvesting, Fire, Northward range shifts, Québec forest inventory, Temperate-boreal ecotone, Tree migration, Sapling recruitment.

\pagebreak

# Introduction

## p1: recruitment = critical step to migration


Climate change significantly impacts the entire tree life cycle, from recruitment to growth and mortality [@vanderwel_climate-related_2013; @zhang_half-century_2015], leading to modifications in population dynamics and species distribution. Given the long-term nature of growth and mortality processes, recruitment is expected to be the primary driver of climate-induced shifts [@woodall_indicator_2009]. Juvenile trees, being more sensitive to environmental variation than adult trees (**Walck et al. 2011**), can serve as an early indicator of species distribution shifts in response to climate warming [@anderson-teixeira_altered_2013; @zhu_failure_2012; @boisvert-marsh_shifting_2014; @sittaro_tree_2017]. Indeed, many tree species in eastern North America have shown northward shifts in their range limits and abundance distribution, with saplings displaying more pronounced changes than adult trees [@boisvert-marsh_shifting_2014; @sittaro_tree_2017; @fei_divergence_2017]. However, the relation between these shifts and climate warming is complex and often weak [@boisvert-marsh_shifting_2014; @sittaro_tree_2017; @fei_divergence_2017], suggesting that tree responses are influenced by a complex interplay of environmental drivers [@solarik_priority_2019; @carteron_soil_2020; @boisvertmarsh_divergent_2019; @leithead_northward_2010]. As successful recruitments beyond current range limits determine tree migration, understanding the conditions that facilitate or impede sapling establishment becomes pivotal in predicting future tree species distributions [@copenhaverparry_multiscale_2020].


*presence vs abundance* Canham et Thomas + Fei et al + LeSquin


## p2: disturbances = catalyst or impediment

Disturbances play a crucial role in natural forest dynamics, initiating succession through tree recruitment within canopy gaps [@attiwill_disturbance_1994]. A growing body of literature therefore suggests disturbances could accelerate tree range shifts [@brice_moderate_2020; @turner_disturbance_2010; @renwick_temporal_2015; @serra-diaz_disturbance_2015]. For instance, moderate disturbances (i.e., 25-75% basal area reduction) have led to an increased proportion of warm-adapted tree species [@brice_disturbances_2019], thereby promoting transitions from mixed to temperate forests across Québec [@brice_moderate_2020]. However, these changes in basal area were primarily driven by the mortality of a dominant boreal species at its trailing edge, followed by the growth release of co-occurring temperate species [@brice_moderate_2020], while the contribution of sapling recruitment was not considered as only merchantable size trees were analyzed. 

Other empirical studies on the role of disturbances in sapling recruitment within transition zones can offer further insights but yield conflicting conclusions. While @leithead_northward_2010 showed that canopy gaps locally facilitate establishment of temperate species in mixed forests of Ontario, @boisvertmarsh_divergent_2019 found a weak and generally negative effect of disturbances on temperate sapling occurrence gain at their northern range limits at a regional scale. These discrepancies could stem from difference in spatial scales, but also from difference in disturbance types. Further research is needed to assess how specific disturbance types, such as harvesting, fires and insect outbreaks, could accelerate broad-scale species migration through regeneration.

Disturbances can trigger pulse recruitment events, where sudden light and space availability allows the establishment of new tree species. The characteristics of disturbances, including type, frequency, severity, and size, influence which species are able to establish depending on several species traits, such as shade-tolerance, dispersal ability and vegetative reproduction [@bergeron_species_2000; @brisson_les_1988]. For example, stand-replacing fires typically favor the return of fire-adapted species like those with (semi-)serotinous cones (e.g., jack pine and black spruce). Fires have been In contrast, clearcuts, although intended to mimic the effects of frequent and severe fires in boreal forests [@bergeron_natural_2002], tend to promote intolerant hardwood species over conifers [@mcrae_comparisons_2001]. Therefore, different disturbances can lead to alternative successional trajectories, holding significant potential to shape future forest composition and distribution in the context of climate change.



*novelty* = TSD, distinguish disturbance types, presence and abundance


## p3: migration lag and other factors

In addition to disturbances, several other biotic and abiotic
factors could influence recruitment.

Despite this migration, these species are still far beyond their fundamental climate niche. This lag between climate change and range shifts can be described in terms of colonization credit and extinction debt (Talluto et al. 2017). Extinction debt refers to the geographic range where a species is still present even though climatic conditions are no longer suitable, while colonization credit represents the geographic range where a species is absent but could be present based on climatic conditions. This delay is partly due to short-range dispersion and competition with native species that may still be present. It also indicates that trees are responding not only to climate warming but also to other biotic and abiotic constraints that could affect the juvenile stage (Boisvert‐Marsh et al., 2019; Carteron et al. 2020; Solarik et al. 2020).  While climate change may be a driver of species migration, the presence of boreal forest can reduce the establishment of temperate species saplings through competition or alteration of soil quality (Solarik et al. 2020). However, results on the direct impact of soil characteristics, such as pH, nutrients, and mycorrhizal composition, are not unanimous. While some laboratory experiments have shown that temperate seedling survival is lower on boreal soils (Carteron et al. 2020), in situ observations have failed to support its importance and have shown that the effects of soil conditions are weak compared to temperature and the composition of the overstory (Barras and Kellman 1998; Fisichelli, Frelich, and Reich 2014). Understanding whether these local conditions can facilitate or inhibit sapling establishment is necessary to predict future tree species ranges and potential lags.

Despite a pressing need to be able to predict the effects of climate change on the distribution and abundance of temperate tree species, we still have only rudimentary understanding of how these different factors interplay to affect recruitment processes.

It seems clear that climate must play a preeminent role in at least the range boundaries of temperate tree species (Simova et al. 2015), but it is much less clear how important climate is in determining the spatial distribution and abundance of a species within its range, particularly given the myriad other factors that influence the presence and abundance of tree species within a stand (Morin et al. 2007).

## models...

Many models...
But these models typically ignore recruitment processes and species interactions that may result in strong inertia in community composition under climate change, and they ignore the expected successional trajectories that have been triggered by natural and human disturbances. 

Apart from the recent range shift studies, juveniles remain an understudied life stage. Moreover, even though forests have benefited from a great attention and modelling effort due to their economic importance, juvenile stages are often oversimplified (Greene et al. 1999). Since only merchantable size trees are considered in management studies, any discrepancy between the overstory and the understory are discarded. However, multiple studies have found that tree population dynamics  are highly dependent on recruitment (Brown and Wu 2005) and that the accuracy of forest models is increased by including the dynamics of seedlings and saplings (Rijal et al. 2022). 

p4: objectives

# Materials and Methods 

## Study area  

The present study focuses on the boreal-temperate ecotone of Québec forests, from the Sugar maple-basswood domain (in the deciduous zone) to the Balsam fir-white birch domain (in the mixed boreal zone; Fig. 1), located between latitude 46.7° and 49.2° and longitude -64.1° and -79.5° (Fig. 1). The Balsam fir-yellow birch domain serves as a transitional zone between the northern temperate and boreal zones. It is characterized by mixed stands of yellow birch and balsam fir. Maple stands are still relatively common in this sub-region, along with other temperate species. There is a strong latitudinal climate gradient in this region (3°C of mean temperature difference over 150km; **Fig. SUPP**) impacting the distribution of species and disturbances. The natural disturbance regimes vary considerably along the latitudinal gradient of the study area, with more frequent large-scale fires and insect outbreaks, which are mainly caused by the spruce budworm that predominantly attacks *Abies balsamea*, in the north than in the south. Similarly, clearcuts are more frequent in northern regions, while in southern regions partial cuts are more common (**Fig. SUPP**).

<!--add figure 1 - map of study area + plots-->

## Forest inventory data 

We analyzed tree recruitment dynamics using data from the permanent forest inventory plots from the Ministère des ressources naturelles et des forêts of Québec. The inventory data consist of 50 183 measures on 12 802 permanent plots covering southern Quebec (from latitude 45° to 52°N and longitude 57° to 80°W) in six bioclimatic domains (MRNF, 2016). Monitoring started in 1970 and is still ongoing and each plot was surveyed approximately every 10 years (3 surveys per plot on average).  

Within each circular plots (400 m^2^, 11.28 m radius), all adult trees with a diameter at breast height (DBH) larger than 9 cm are identified, numbered and measured. Saplings, defined as trees with a DBH between 1 and 9 cm, are identified, counted and categorized into four size classes (DBH: 1-3, 3-5, 5-7 and 7-9 cm) within a 3.57m radius subplot (40 m2). *We decided to focus our analysis on the smallest class (1-3 cm) because...* 

For our analyses, we first selected all permanent inventory plots in the ecological domain of the *Balsam fir-yellow birch* that had been sampled at least twice. As we were interested in natural regeneration succession processes, we only kept plots that were undisturbed or had a known year of disturbance and excluded plots subjected to active reforestation by plantation. Windfall disturbance events were too infrequent to reliably estimate their effects and discarded as well. *Finally, we kept plots for which all studied environmental predictors were measured* (see below; Table 1). In total, **3988** measurements were selected for all species, collected from **920** plots spanning the period from 1971 to 2021 (Fig. 1? <!--add a map of study area + plots-->). 

## Disturbance variables

We also collected information pertaining to natural and anthropogenic disturbances that have affected the forest plots during the study period (Table 1; Fig. **SUPP**). Anthropogenic disturbances were classified into three categories: partial cut (**234** plots), clearcut (**115** plots), and CPRS (**179** plots). Natural disturbances, on the other hand, were not differentiated between partial and total disturbances due to their limited occurrence. The two types of natural disturbances considered were fire events (**167** plots) and outbreak events (**68** plots). The effects of each disturbance were assessed for subsequent measurements until a new total disturbance (either fire or cut) occurred. In instances where a disturbance event coincided with the year of a measurement, the basal area was used to determine if the disturbance preceded or followed the measurement. A total of **263** plots remained undisturbed during the study period. 

## Local biotic and abiotic variables 

In each permanent plot, several edaphic characteristics were recorded (MRNF, 2016). Among consistently recorded characteristics, we selected humus pH and organic matter thickness because they largely affect nutrient availability, soil structural properties and vegetation development (Tan 2011). We also selected drainage (xeric, mesic, hydric), and altitude at first but due to correlation with organic matter thickness and temperature respectively we did not keep them in the final model. When possible, missing soil characteristics were imputed using preceding or following measurements within the same plot. 

We measured the total tree basal area of all adult trees (DBH > 9cm) to include an approximate index of local competition in our model. Similarly, we also included the presence of conspecific adult trees of the focal species (i.e. one of the six temperate species under investigation) to take into account potential local seed availability. 

## Climatic variables 

Climatic variables were extracted from the ANUSPLIN climate modelling software (McKenney et al. 2011). These data contain various bioclimatic variables on a 2-km2 grid-scale on a yearly basis from 1960 to 2020. Among them, we selected two variables hypothesized to influence tree establishment, survival and growth (**ref**): mean temperature and climate moisture index. To account for the effect of multiple preceding years on the observed recruitment process we used the mean of each climate variable over 10 years. As data for 2021 was not available at the time of analysis, we took the mean over 2010 to 2020 for both 2020 and 2021. **During the study period, temperatures have increased by **XX** °C/decade in the plots, while CMI have shown no significant trend (Fig. SUPP), but the magnitude of climate change varies across the study area (Fig. SUPP).** 

**Table 1**: Description of the explanatory variables used in the hurdle models of tree recruitment.

<!--add table-->

## Regeneration models 

Recruitment in each plot is represented as a count variable, i.e., the number of saplings. Because of the nature of regeneration process and the vast area covered in this study, recruitment data present a large number of zeros. Absence of a species at the sapling stage in the data is overrepresented compared to what is expected at random from count distributions, such as Poisson and negative binomial (Zuur et al. 2009). To account for this, we choose to consider zeros separately using a hurdle model. From an ecological standpoint, this allows to differentiate between two characteristics of sapling recruitment: presence and abundance. These two processes can be influenced by different parameters and thus modeling them separately allows for a finer interpretation. Like the zero-inflated model, the hurdle model is divided in two parts, but it accounts for zeros in a separate manner. In the first part of the model, the probability of presence ($p_i$) is modeled as a binomial process using a logistic regression with explanatory variables. In the second part of the model, for plots where saplings are present, the abundance ($lambda_i$) is modeled as a Poisson Truncated at 0 (noted $T(0)$). For each measure i, it can be written as:

$$Presence_i \sim Bernoulli(p_i)$$

$$Abundance_i \sim   
  \begin{cases}
    0        & \quad \text{if } Presence_i = 0\\
    Poisson(\lambda_i)T(0)  & \quad \text{if } Presence_i > 0
  \end{cases} \text{,}
$$

<!--dans mon projet, j'avais initialement utilisé un negative binomial car il y avait de l'overdispersion... vérfier?-->

### Modeling spatio-temporal shift in sapling distribution 

To evaluate possible spatial or temporal shift in sapling distribution of each species, we first analyzed the effects of time and latitude on recruitment in the ecotone and the two adjacent subdomains (sugar maple-yellow birch, to the south, and balsam fir-paper birch domain, to the north). In this model, sapling distribution $p_i$ and $lambda_i$ were defined as a regression against time and latitude as well as their interaction with a random effect on plots. This simple model of spatio-temporal shift in sapling recruitment was run with glmmTMB package (Brooks et al. 2017) as a generalized linear model in two parts with a binomial family for the presence and a truncated poisson for abundance. 

### Modeling environmental drivers of sapling distribution 

To identify environmental drivers of sapling recruitment in the ecotone, the probability of zeros $P(Y = 0) = \p_i$ and the mean $\lambda_i$ of positive count data in a forest plot $j$ were modeled as a regression of a set of covariates $Z_{i}$
and $X_{i}$ (Table 1) with respectively logit and log as a link function: 

$$ logit(p_i) = \gamma_0 + \sum_j \gamma_j \times Z_{ij} + Plot_i,$$

$$log(\lambda_i) = \beta_0 + \sum_j \beta_j \times X_{ij} + Plot_i.$$


<!--comment coder disturbances
The bd,∆T factors represent the effect of each disturbance d after time ∆T on presence (respectively 𝛽d,∆T for abundance). -->

To simplify the effect of time since disturbance (TSD) in our model, we classified time in discrete periods: 10 (ranging from 5 to 15 years), 20 (15 to 25), 30 (25 to 35), 50 (45 to 55), 75 (70 to 80) and 90 (90 to 100) years after disturbances.<!--as-tu enlevé des données? 0 à 5? 56 à 74? >100? etc. pourquoi pas les inclure dans une période?--> Because different disturbance types have different temporal coverage, we used different time periods for each disturbance. For fire, we used the three largest categories; for clearcut and partial cut, we used the first three categories; and for CPRS, we used the first two categories.

As we were interested on the direct effect of disturbances, we wanted to take into account the indirect impact of disturbances through changes in basal area. To do so, we incorporated a basal area submodule into our model. We first modeled basal area as a normal distribution (with a standard deviation $\sigma$) centered around a linear regression based on time since disturbance: 

$$BA_i \sim N(\mu_i, \sigma),$$ 

where

$$\mu_i \sim \mu0 + \sum_d(D_{d,i} \times (\omega_{0,d} + \omega_{1,d} \times TSD_{d,i} + \omega_{2,d} \times TSD_{d,i}^2)).$$

<!--vérifier l'équation-->

The parameter $\mu0$ represents the mean basal area of plots without disturbance. We included the second order polynomial term only for time since fire because the longer time period allowed to reach a plateau. We then used the residual basal area ($BA_{res.i} = BA_i - \mu_i$), instead of the raw basal area, as a covariate in the hurdle model to consider the effect of basal area variation around the mean for each plot and measure. This submodule enables us to eliminate the indirect effects while maintaining the plot's distinctiveness in terms of canopy cover. 

<!--j'ai pas mal simplifier le passage sur les perturbations, est-ce que c'est clair? vérifier.-->

Every quantitative covariate was standardized prior to running the model. To consider the repeated measures on the same plot and structure in our data, a random effect on plot was added, with a uniform prior on the hyperparameters. 

### Model implementation and validation 

The more complete model including disturbances and covariates was coded in a Bayesian framework. It allows for more flexibility and the possibility to integrate different processes in the model (here presence and abundance, multiple disturbances, their over lasting consequences and sub-models for the indirect effect of disturbance through basal area). We chose uniform priors over the interval [-50,50].<!--justifier les uniform priors?--> This model was coded in JAGS (Plummer 2017) and run using the library R2jags (Yu-Sung and Yajima 2020). We extracted the results for 3 Markov Chain Monte Carlo (MCMC) containing 4000 iterations of which half for burnin (2h for each species). We checked convergence with the potential scale reduction factor (Rhat ~ 1) and effective sample size (> 100) for each parameter.  

All analyses were performed using R Statistical Software (v4.2.2; R Core Team 2021). All data used in the study, in addition to R scripts that reproduced the analyses and figures are available on github (link). 

# Results

# Conclusions

\pagebreak

# References