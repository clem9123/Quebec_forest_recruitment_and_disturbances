Run_jags <- function(sp, model_file, name, n.iter = 500){
    # 1. Start timer
    begin = Sys.time()
    print(begin)
    # 2. Load data
    jags_data <- make_jags_data(sp)
    # 3. Run model
    param = c(
        # ba
        #"ba_intercept",
        #"ba_l0", "ba_l1",
        #"ba_pl0", "ba_pl1",
        #"ba_lpr0", "ba_lpr1",
        #"ba_b0", "ba_b1", "ba_b2",
        #"ba_o0", "ba_o1",
        #"mu_ba", "BA_res",s
        # densite
        "nb_intercept", "nb_altitude", "nb_epmatorg", "nb_ph", "nb_ph2","nb_epmatorg2",
        "nb_cl_drai", "nb_tmean", "nb_cmi", "nb_species", "nb_year", "nb_ba", "nb_sp","nb_sp2",
        "nb_tmean2", "nb_cmi2", "nb_texture",
        "nb_l0", "nb_l1", "nb_l2",
        "nb_pl0", "nb_pl1", "nb_pl2",
        "nb_lpr0", "nb_lpr1", "nb_lpr2",
        "nb_b0", "nb_b1", "nb_b2",
        "nb_o0", "nb_o1", "nb_o2",
        #"nb_placette",
        "nb_taupl",
        # presence
        "pa_intercept", "pa_altitude", "pa_epmatorg", "pa_epmatorg2",
        "pa_ph", "pa_ph2", "pa_tmean2", "pa_cmi2", "pa_texture", "pa_sp","pa_sp2",
        "pa_cl_drai", "pa_tmean", "pa_cmi", "pa_species", "pa_year", "pa_ba",
        "pa_l0", "pa_l1", "pa_l2",
        "pa_pl0", "pa_pl1", "pa_pl2",
        "pa_lpr0", "pa_lpr1", "pa_lpr2",
        "pa_b0", "pa_b1", "pa_b2",
        "pa_o0", "pa_o1", "pa_o2",
        #"pa_placette",
        "pa_taupl",
        # Residus et prediction
        "Res_pa", "Res_nb", "Pred_pa", "Pred_nb", "Pred_nb2",
        "Log_likelihood", "Log_likelihood2"
        # Autres
        #"p", "lambda"
    )

    out <- jags.parallel(
        model.file = model_file,
        data = jags_data,
        parameters.to.save = param,
        n.chains = 3,
        n.iter = n.iter)

    # 4. Stop timer
    Tex <- Sys.time() - begin
    out$runtime <- Tex
    print(Tex)

    # 5. Save results
    saveRDS(out, file = paste0(name, "", sp, ".rds"))}

make_jags_data <- function(sp){

load("full_data.RData")

# 2. Prepare data
#----------------
data <- full_data %>% filter(sp_code == sp, dom_bio %in% c(4,5)) %>% na.omit()
# create the list of data to be used in the model
jags_data <- list(
    # data to fit
    N = nrow(data),
    PRESENCE = data$presence_gaule, # is_recrues
    DENSITE = data$all_cl, # recrues
    # variables
    YEAR = data$year_measured_sc,
    LATITUDE = data$latitude_sc,
    LONGITUDE = data$longitude_sc,
    ALTITUDE = data$altitude_sc,
    EPMATORG = data$epmatorg_sc,
    PH = data$ph_humus_sc,
    BA = data$tree_ba_sc,
    IS_SPECIES = data$have_been_species, # have_been_species_recrues
    NB_SP = data$tree_nb_sp,
    TS_L = data$logging_sc,
    TS_PL = data$partial_logging_sc,
    TS_LPR = data$logging_pr_sc,
    TS_B = data$burn_sc,
    TS_O = data$outbreak_sc,
    IS_PL= data$is_partial_logging,
    IS_L = data$is_logging,
    IS_LPR = data$is_logging_pr,
    IS_B = data$is_burn,
    IS_O = data$is_outbreak,
    PLACETTE = data$id_pe_sc,
    N_PLACETTE = max(data$id_pe_sc),
    CL_DRAI = data$cl_drai_sc,
    TEXTURE = data$texture_sc,
    TMEAN = data$an_meanT_sc,
    CMI = data$cmi_sum_sc,
    TEXTURE = as.numeric(data$texture_sc),
    CL_L = data$cl_logging,
    CL_PL = data$cl_partial_logging,
    CL_LPR = data$cl_logging_pr,
    CL_B = data$cl_burn,
    CL_O = data$cl_outbreak)

return(jags_data)}