library(QuebecSaplingsRecruitment)
args <- commandArgs(trailingOnly = TRUE)
run_jags_model(
    list_species()[args[1] |> as.numeric()], 
    "model_time_class_without_ba.bugs", 
    n.chains = 5, 
    n.iter = 10000, 
    n.burnin = 5000,
    n.thin = 1,
    devel = FALSE
)