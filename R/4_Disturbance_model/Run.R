####################################

## Run everything in parallel
#-------------

library(parallel)

print("running")
source("R/4_Disturbance_model/function_run.R")
Myspecies = c("ABIBAL", "ACERUB", "ACESAC", "BETALL",
    "PICMAR", "PICGLA", "BETPAP", "POPTRE")

cl <- makeCluster(15) # attention verifier le nombre de coeur de votre ordinateur

clusterExport(cl, c("make_jags_data", "Run_jags", "Myspecies"), 
              envir=environment())
clusterEvalQ(cl, c(library(tidyverse), library(R2jags)))


parLapply(cl, Myspecies, function(x) Run_jags(x, "R/4_Disturbance_model/Model.txt", "output/heavy/withoutBA/", n.iter = 2000))

stopCluster(cl)
    
print("finish running")