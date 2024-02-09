run_jags_model <- function(sp, model_file, name, n.iter = 500, path = "data/full_data.RData") {
    ############################################################################

    ### Function taking a species name as argument and running the jags model
    ### it uploads the data, transform it into a list (the usable object for JAGS) and run the model
    ### return a jags.parallel object

    ############################################################################

    # 1. Start timer
    begin <- Sys.time()
    print(begin)
    # 2. Load data
    jags_data <- make_jags_data(sp, path)
    # 3. Run model
    param <- c(
        # ba (basal area)
        "ba_intercept",
        "ba_l0", "ba_l1",
        "ba_pl0", "ba_pl1",
        "ba_lpr0", "ba_lpr1",
        "ba_b0", "ba_b1", "ba_b2",
        "ba_o0", "ba_o1",
        # pa (presence/absence)
        "pa_intercept",
        "pa_epmatorg", "pa_ph", "pa_soil",
        "pa_tmean", "pa_tmean2", "pa_cmi", "pa_cmi2",
        "pa_sp", "pa_sp2", "pa_ba",
        "pa_l", "pa_pl", "pa_lpr", "pa_b", "pa_o",
        "pa_taupl",
        # nb (abundance)
        "nb_intercept",
        "nb_epmatorg", "nb_ph", "nb_soil",
        "nb_tmean", "nb_tmean2", "nb_cmi", "nb_cmi2",
        "nb_sp", "nb_sp2", "nb_ba",
        "nb_l", "nb_pl", "nb_lpr", "nb_b", "nb_o",
        "nb_taupl"
    )

    out <- jags.parallel(
        model.file = model_file,
        data = jags_data,
        parameters.to.save = param,
        n.chains = 3,
        n.iter = n.iter
    )

    # 4. Stop timer
    Tex <- Sys.time() - begin
    out$runtime <- Tex
    print(Tex)

    # 5. Save results
    saveRDS(out, file = paste0(name, "", sp, ".rds"))
}

make_jags_data <- function(sp, path) {
    load(path)

    # 2. Prepare data
    #----------------
    data <- full_data |>
        filter(sp_code == sp) |>
        sample_n(2000)
    # create the list of data to be used in the model
    jags_data <- list(
        # data to fit
        N = nrow(data),
        PRESENCE = data$presence_gaule, # is_recrues
        DENSITE = data$all_cl, # recrues
        # variables
        EPMATORG = data$epmatorg_sc,
        PH = data$ph_humus_sc,
        BA = data$tree_ba_sc,
        IS_SPECIES = data$have_been_species, # have_been_species_recrues
        NB_SP = data$tree_nb_sp,
        TS_L = data$logging_sc, # TS = Time since
        TS_PL = data$partial_logging_sc,
        TS_LPR = data$logging_pr_sc,
        TS_B = data$burn_sc,
        TS_O = data$outbreak_sc,
        IS_PL = data$is_partial_logging,
        IS_L = data$is_logging,
        IS_LPR = data$is_logging_pr,
        IS_B = data$is_burn,
        IS_O = data$is_outbreak,
        PLACETTE = data$id_pe_sc,
        N_PLACETTE = max(data$id_pe_sc),
        TMEAN = data$an_meanT_sc,
        CMI = data$cmi_sum_sc,
        SOIL = as.numeric(data$soil),
        CL_L = data$cl_logging,
        CL_PL = data$cl_partial_logging,
        CL_LPR = data$cl_logging_pr,
        CL_B = data$cl_burn,
        CL_O = data$cl_outbreak
    )

    return(jags_data)
}