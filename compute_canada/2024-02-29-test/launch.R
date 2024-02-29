library(QuebecSaplingsRecruitment)
args <- commandArgs(trailingOnly = TRUE)
run_jags_model(
    list_species()[args[1] |> as.numeric()], 
    "model_time_class.bug", 
    n.chains = 5, 
    n.iter = 100, 
    devel = TRUE
)