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


parLapply(cl, Myspecies, function(x) Run_jags(x, "Model.txt", "output/", n.iter = 500))

stopCluster(cl)
    
print("finish running")

####################################

## Run once for testing
#-------------


## library
library(tidyverse)
library(R2jags)
## function
source("R/4_Disturbance_model/function_run.R")
## run
Run_jags("ACERUB", "R/4_Disturbance_model/Model.txt", "output/heavy/", n.iter = 2000, "data/full_data.RData")
Run_jags("ACERUB", "R/4_Disturbance_model/Model1.txt", "output/heavy/1", n.iter = 2000, "data/full_data.RData")
Run_jags("ACERUB", "R/4_Disturbance_model/Model2.txt", "output/heavy/2", n.iter = 2000, "data/full_data.RData")
Run_jags("ACERUB", "R/4_Disturbance_model/Model3.txt", "output/heavy/3", n.iter = 2000, "data/full_data.RData")
Run_jags("ACERUB", "R/4_Disturbance_model/Model4.txt", "output/heavy/4", n.iter = 4000, "data/full_data.RData")
Run_jags("ACERUB", "R/4_Disturbance_model/Model5.txt", "output/heavy/5", n.iter = 4000, "data/full_data.RData")


out = readRDS("output/heavy/ACERUB.rds")
out1 = readRDS("output/heavy/1ACERUB.rds")
out2 = readRDS("output/heavy/2ACERUB.rds")
out3 = readRDS("output/heavy/3ACERUB.rds")
out4 = readRDS("output/heavy/4ACERUB.rds")
out5 = readRDS("output/heavy/5ACERUB.rds")

traceplot(out, var = "pa_intercept", ask = FALSE)
traceplot(out1, var = "pa_intercept", ask = FALSE)
traceplot(out2, var = "pa_intercept", ask = FALSE)
traceplot(out3, var = "pa_intercept", ask = FALSE)
traceplot(out4, var = "pa_intercept", ask = FALSE)
traceplot(out5, var = "pa_intercept", ask = FALSE)


dgamma(0.1,0.1)
plot(density(rgamma(10000,0.1,0.1)))
