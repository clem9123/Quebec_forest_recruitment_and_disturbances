####################################

## Run everything in parallel
#-------------

library(parallel)

print("running")
source("function_run.R")
Myspecies = c("ABIBAL", "ACERUB", "ACESAC", "BETALL",
    "PICMAR", "PICGLA", "BETPAP", "POPTRE")

cl <- makeCluster(30) # attention verifier le nombre de coeur de votre ordinateur

clusterExport(cl, c("make_jags_data", "Run_jags", "Myspecies"), 
              envir=environment())
clusterEvalQ(cl, c(library(tidyverse), library(R2jags)))


parLapply(cl, Myspecies, function(x) Run_jags(x, "Model.txt", "output/", n.iter = 4000))

stopCluster(cl)
    
print("finish running")

####################################

## Run once for testing
#-------------


## library
#library(tidyverse)
#library(R2jags)
## function
#source("R/8_Disturbance_model/function_run.R")
## run
#Run_jags("PICGLA", "R/8_Disturbance_model/Model.txt", "output", n.iter = 200)
