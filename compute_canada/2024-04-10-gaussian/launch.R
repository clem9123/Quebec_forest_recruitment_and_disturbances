library(QuebecSaplingsRecruitment)
args <- commandArgs(trailingOnly = TRUE)
run_jags_model(
    list_species()[args[1] |> as.numeric()], 
    "model_continuous_time_normal.bugs", 
    n.chains = 5, 
    n.iter = 25000, 
    n.burnin = 5000,
    n.thin = 1,
    devel = FALSE
)