####################################

## Run everything in parallel
#-------------

library(parallel)

print("running")
source("R/4_Disturbance_model/function_run.R")
Myspecies = c("ACERUB", "ACESAC") # c("ABIBAL", "ACERUB", "ACESAC", "BETALL", "PICMAR", "PICGLA", "BETPAP", "POPTRE")

cl <- makeCluster(8) # attention verifier le nombre de coeur de votre ordinateur

clusterExport(cl, c("make_jags_data", "run_jags_model", "Myspecies"), 
              envir=environment())
clusterEvalQ(cl, c(library(tidyverse), library(R2jags)))


parLapply(cl, Myspecies, function(x) run_jags_model(x, "R/4_Disturbance_model/Model.txt", "output/heavy/withoutBA/", n.iter = 2000))

stopCluster(cl)
    
print("finish running")