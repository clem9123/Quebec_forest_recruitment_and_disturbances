all_param_table <- function(transform = FALSE){

    ############################################################################

    ### Function creating a table with all parameters of the models
    ### for each part of the model (pa -presence/absence- and nb -number of saplings-)
    ### return a data frame with all parameters for each species and each model (nb and pa), their mean, min and max
    ### and if the parameter is significatif or not (if the 95% CI cross 0 or not)
    ### and if the effect is positive or negative (if the mean is < or > 0)

    ############################################################################

    ## Make the table by taking the mean and quantile of each parameter distribution
    # -------------------------------------------------------------------

    Coef = c("tmean", "epmatorg", "cmi", "ba", "ph", "tmean2", "cmi2")
    # sp", "sp2", 
    all_param <- data.frame()
    for (sp in Mysp){
        for (part in c("pa","nb")){
            model = get(paste0("Model_",sp))
            for (param in Coef){
        distrib_param <- model$BUGSoutput$sims.list[paste0(part,"_", param)][[1]]
        all_param <- rbind(all_param, data.frame(
            sp = sp,
            mean = mean(distrib_param),
            min = quantile(distrib_param, 0.025) %>% as.numeric(),
            max = quantile(distrib_param, 0.975) %>% as.numeric(),
            var = param,
            type = part)) 
    }
            ## pour conspecific
            distrib_param <- model$BUGSoutput$sims.list[paste0(part,"_","intercept")][[1]][,2] - model$BUGSoutput$sims.list[paste0(part,"_","intercept")][[1]][,1]
            all_param <- rbind(all_param, data.frame(
                sp = sp,
                mean = mean(distrib_param),
                min = quantile(distrib_param, 0.025) %>% as.numeric(),
                max = quantile(distrib_param, 0.975) %>% as.numeric(),
                var = "sp",
                type = part))
            }
    }

    # Add significance (95%) and effect (+/-)
    all_param <- all_param %>%
        mutate(significatif = ifelse(min < 0 & max > 0, "non", "oui"),
            effet = ifelse(mean < 0, "negatif", "positif"))

    ## Order table and specify factor names by species and parameter
    # -------------------------------------------------------------------

    all_param <- all_param %>% mutate(sp = factor(sp, levels = c("ACERUB", "ACESAC", "BETALL", "BETPAP", "ABIBAL", "PICGLA", "PICMAR", "POPTRE")))
    # rename species with their scientific name
    all_param <- all_param %>% mutate(type_sp = case_when(sp %in% c("ACERUB", "ACESAC", "BETALL") ~ "Temperate",
        sp %in% c("ABIBAL", "PICGLA", "PICMAR") ~ "Boreal",
        sp %in% c("BETPAP", "POPTRE") ~ "Pionner"))
    all_param <- all_param %>% 
        mutate(sp = case_when(
            sp == "ACERUB" ~ "A. rubrum",
            sp == "ACESAC" ~ "A.saccharum",
            sp == "BETALL" ~ " B. alleghaniensis",
            sp == "POPTRE" ~ "P. tremuloides",
            sp == "BETPAP" ~ "B. papyrifera",
            sp == "ABIBAL" ~ "A. balsamea",
            sp == "PICGLA" ~ "P. glauca",
            sp == "PICMAR" ~ "P. mariana"))
    all_param <- all_param %>% mutate(var = factor(var, levels = c("sp", "ba", "ph", "ph2", "epmatorg", "epmatorg2", "cmi", "cmi2", "tmean", "tmean2"),
    labels = c("Conspecific", "Basal area", "Humus pH", "Humus pH^2", "Organic matter" ,"Organic matter^2", "CMI", "CMI^2", "Mean temperature","Mean temperature^2")))
    all_param <- all_param %>% mutate(sp = factor(sp,
        levels = rev(c("A. rubrum", "A.saccharum",
        " B. alleghaniensis", "P. tremuloides", "B. papyrifera", "A. balsamea", "P. glauca", "P. mariana"))))

    return(all_param)
}

all_param_plot <- function(list_coef = 
    c("Conspecific", "Conspecific^2", "Intercept", "Basal area", "Humus pH",
    "Humus pH^2", "Organic matter" ,"Organic matter^2", "CMI", "CMI^2",
    "Mean temperature","Mean temperature^2")){

    ############################################################################

    ### Function creating a plot with all parameters of the models (using the output of all_param_table)
    ### Plots all parameters in list_coef (default = all parameters)
    ### return a ggplot object

    ############################################################################

p1 <- ggplot(all_param %>% filter(type == "pa", var %in% list_coef)) +
    geom_linerange(aes(x = sp, ymin = min, ymax = max, color = effet)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    geom_point(aes(x = sp, y = mean,
        color = effet, fill = paste0(effet,significatif)),
        shape = 21, size = 3, stroke = 2) +
    scale_fill_manual(values = 
        c("positifoui" = "blue","negatifoui" = "red",
        "negatifnon" = "#ffffff", "positifnon" = "white")) +
    scale_color_manual(values = c("negatif" = "red", "positif" = "blue")) +
    facet_wrap(~ var, ncol = 2, scale = "free_y") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    guides(fill = "none", color = "none") +
    labs(x = "", y = "estimate") +
    # ecrire x en italic
    theme(axis.text.x = element_text(face = "italic", size = 12))
p2 <- ggplot(all_param %>% filter(type == "nb", var %in% list_coef)) +
    geom_linerange(aes(x = sp, ymin = min, ymax = max, color = effet)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    geom_point(aes(x = sp, y = mean,
        color = effet, fill = paste0(effet,significatif)),
        shape = 21, size = 3, stroke = 2) +
    scale_fill_manual(values = 
        c("positifoui" = "blue","negatifoui" = "red",
        "negatifnon" = "#ffffff", "positifnon" = "white")) +
    scale_color_manual(values = c("negatif" = "red", "positif" = "blue")) +
    facet_wrap(~ var, ncol = 2, scale = "free_y") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    guides(fill = "none", color = "none") +
    labs(x = "", y = "") +
    # ecrire x en italic
    theme(axis.text.x = element_text(face = "italic", size = 12))

 return (p1 + labs(title = "Presence") +
    p2 + labs(title = "Abondance"))
}

soil_param_table <- function(){
    ############################################################################

    ### Function creating a table with distribution of parameters for the soil pa_soil[1:7] and nb_soil[1:7]
    ### return a data.frame with the mean, min and max of the distribution of each parameter,
    ### if the parameter is significatif or not (if the 95% CI cross 0 or not)
    ### For each species and each model part (pa or nb)

    ############################################################################

    soil_param <- data.frame()
    for (sp in Mysp){
        for (part in c("pa","nb")){
            model = get(paste0("Model_",sp))
                for (i in 1:6){
                distrib_param <- model$BUGSoutput$sims.list[paste0(part,"_", "soil")][[1]][,i] + model$BUGSoutput$sims.list[paste0(part,"_", "intercept")][[1]]
                soil_param <- rbind(soil_param, data.frame(
                    sp = sp,
                    mean = mean(distrib_param),
                    min = quantile(distrib_param, 0.025) %>% as.numeric(),
                    max = quantile(distrib_param, 0.975) %>% as.numeric(),
                    type = part,
                    soil = i))
    }}}
    return(soil_param)
}


quadratic_table <- function(list_coef = c("cmi", "tmean"), transform = FALSE){

    ############################################################################

    ### Function creating a table with the quadratic effects of the coef in list_coef
    ### return a data.frame

    ############################################################################

    quadratic <- data.frame()
    # For each covariable create a list of value covering the range of the variable (in the data) of legth 20
    epmatorg = seq(1,25,length.out = 20)
    ph = seq(4,5,length.out = 20)
    tmean = seq(-1,3,length.out = 20)
    cmi = seq(30,100,length.out = 20)
    sp = seq(1,40,length.out = 20)
    # extract the scaling coefficient used to make the data and fitting the model
    epmatorg_sd = as.numeric(scaling[which(scaling$var == "epmatorg" & scaling$mean_sd == "sd"),]$value)
    epmatorg_mean = as.numeric(scaling[which(scaling$var == "epmatorg" & scaling$mean_sd == "mean"),]$value)
    ph_sd = as.numeric(scaling[which(scaling$var == "ph_humus" & scaling$mean_sd == "sd"),]$value)
    ph_mean = as.numeric(scaling[which(scaling$var == "ph_humus" & scaling$mean_sd == "mean"),]$value)
    tmean_sd = as.numeric(scaling[which(scaling$var == "tmean" & scaling$mean_sd == "sd"),]$value)
    tmean_mean = as.numeric(scaling[which(scaling$var == "tmean" & scaling$mean_sd == "mean"),]$value)
    cmi_sd = as.numeric(scaling[which(scaling$var == "cmi" & scaling$mean_sd == "sd"),]$value)
    cmi_mean = as.numeric(scaling[which(scaling$var == "cmi" & scaling$mean_sd == "mean"),]$value)
    # create a list of scaled values for each covariable
    epmatorg_sc = (epmatorg - epmatorg_mean)/epmatorg_sd
    ph_sc = (ph - ph_mean)/ph_sd
    tmean_sc = (tmean - tmean_mean)/tmean_sd
    cmi_sc = (cmi - cmi_mean)/cmi_sd
    sp_sc = sp
    
    for (species in Mysp){
        model <- get(paste0("Model_", species))
        for (part in c("pa","nb")){
            intercept = model$BUGSoutput$sims.list[paste0(part,"_intercept")][[1]][,1]
            for (param in list_coef){
                value = get(param)
                value_sc = get(paste0(param, "_sc"))
                for (i in 1:20){
        coef1 = model$BUGSoutput$sims.list[paste0(part,"_",param)][[1]]
        coef2 = model$BUGSoutput$sims.list[paste0(part,"_",param,"2")][[1]]
        list = intercept + coef1*value_sc[i] + coef2*value_sc[i]^2
        if(transform){if(part == "pa"){list = inv.logit(list)};if(part == "nb"){list = exp(list)}}
        quadratic <- rbind(quadratic, data.frame(
            sp_code = species,
            mean = mean(list) %>% as.numeric(),
            max = quantile(list, 0.975) %>% as.numeric(),
            min = quantile(list, 0.25) %>% as.numeric(),
            var = param,
            part = part,
            value = value[i]))
    }}}}

    # Add significance (95%) and effect (+/-)
quadratic <- quadratic %>%
    mutate(significatif = ifelse(min > 0 | max < 0, "oui", "non"),
        effet = ifelse(mean < 0, "negatif", "positif"))
    return(quadratic)
}

quadratic_plot <- function(coef){

    ############################################################################

    ### Function creating a plot with the quadratic effects of the coef in list_coef
    ### return a ggplot

    ############################################################################

    ## Plot for Presence/Absence
    #---------------------------
    temperate = c("ACERUB", "ACESAC", "BETALL")
    boreal = c("ABIBAL", "PICGLA", "PICMAR")
    pioneer = c("BETPAP", "POPTRE")
    for (p in c("pa", "nb")){
        for (sp_type in c("temperate", "boreal", "pioneer")){
        plot <- 
            ggplot(
                data = quadratic %>% filter(var == coef, part == p, sp_code %in% get(sp_type))) +
            geom_ribbon(aes(x = value, ymin = min, ymax = max), alpha = 0.5) +
            geom_line(aes(x = value, y = mean)) +
            facet_wrap(~sp_code,
                    labeller = as_labeller(c("ACERUB" = "A. rubrum", "ACESAC" = "A. saccharum",
                        "BETALL" = "B. alleghaniensis", "BETPAP" = "B. papyrifera",
                    "POPTRE" = "P. tremuloides", "ABIBAL" = "A. balsamea", "PICGLA" = "P. glauca",
                        "PICMAR" = "P. mariana"))) +
            labs(x = coef, y = "", title = sp_type) +
            theme_bw() +
            theme(legend.position = "none", axis.title.x = element_blank())

        assign(paste0("plot_", sp_type), plot)
        }
layout <- "
AAA
BBB
CC#
"
    assign(paste0("plot_", p), 
        plot_temperate + plot_boreal + plot_pioneer + 
        plot_layout(design = layout))
    }
    return(plot_pa | plot_nb)
}

disturbance_table <- function(part, scatter = TRUE){

    ############################################################################

    ### Function creating a table with the mean and 95% CI of the disturbance
    ### it takes the distribution of the coefficient for the perturbation on interval time t and extract the mean and 95% CI
    ### take a part (pa or nb) and a scatter (TRUE or FALSE) as argument
    ## part is the part of the model presence/absence or number of individuals respectively
    ## scatter is a boolean to add a scatter the different coefficient of the logging 
    ## as they are on the same plot (generally I recommand TRUE for the specific graphic this function makes)
    ### return a data.frame

    ############################################################################

    df <- data.frame()
    for (sp in Mysp){
        model <- get(paste0("Model_", sp))
            for (t in 1:6){
                for (perturb in c("l", "pl", "b","o","lpr")){
                    coefficient <- model$BUGSoutput$sims.list[paste0(part,"_", perturb)][[1]][,t]
                    mean = mean(coefficient) %>% as.numeric()
                    min = quantile(coefficient, 0.025) %>% as.numeric()
                    max = quantile(coefficient, 0.975) %>% as.numeric()
                    df <- rbind(
                        df,
                        data.frame(
                            sp_code = sp,
                            date_perturb = t,
                            perturb = perturb,
                            mean = mean,
                            min = min,
                            max = max))
            }
        }
    }

    # Add significance (95%) and effect (+/-)
    df <- df %>% mutate(
        effet = ifelse(mean > 0, "positif", "negatif"),
        significatif = ifelse(min > 0 | max < 0, "oui", "non"))
        df <- df %>% filter(date_perturb %in% c(1,2,3)) %>%
            filter(!(perturb == "lpr" & date_perturb == 3))

    # Arrange the data
    df <- df %>% mutate(sp_code = factor(sp_code, levels = 
        c("ACERUB","ACESAC", "BETALL", "POPTRE", "BETPAP", "ABIBAL", "PICGLA", "PICMAR")))
    # Discard coefficient whan less than 20 measures existed
    if (part == "nb"){
        df[which(df$sp_code == "BETALL" & df$perturb == "o"), "mean"] <- NA
        df[which(df$sp_code == "BETALL" & df$perturb == "o"), "min"] <- NA
        df[which(df$sp_code == "BETALL" & df$perturb == "o"), "max"] <- NA
        df[which(df$sp_code == "BETALL" & df$perturb == "b"), "mean"] <- NA
        df[which(df$sp_code == "BETALL" & df$perturb == "b"), "min"] <- NA
        df[which(df$sp_code == "BETALL" & df$perturb == "b"), "max"] <- NA
        df[which(df$sp_code == "ACESAC" & df$perturb == "o"), "mean"] <- NA
        df[which(df$sp_code == "ACESAC" & df$perturb == "o"), "min"] <- NA
        df[which(df$sp_code == "ACESAC" & df$perturb == "o"), "max"] <- NA
        df[which(df$sp_code == "PICGLA" & df$perturb == "lpr" & df$date_perturb == 2), "min"] <- -4}
    df <- df %>% mutate(type_sp = case_when(sp_code %in% c("ACERUB", "ACESAC", "BETALL") ~ "temperee",
        sp_code %in% c("ABIBAL", "PICGLA", "PICMAR") ~ "boreale",
        sp_code %in% c("BETPAP", "POPTRE") ~ "pionniere"))
    
    # Add a scatter interval for logging coefficient so they don't overlap
    if (scatter){
        df <- df %>% mutate(date_perturb = 
            ifelse(perturb == "lpr", date_perturb - 0.1, ifelse(
            perturb == "pl", date_perturb + 0.1, date_perturb)))}

    return(df)
}

disturbance_plot <- function(df, a){
    ############################################################################

    ### Function creating a plot with the mean and 95% CI of the disturbance
    ### it takes the data.frame created by the function disturbance_table as argument
    ### return a ggplot object

    ############################################################################

    ## PLOT ATTRIBUTES
    #------------------

    # Species types
    Temperate = c("ACERUB", "ACESAC", "BETALL")
    Boreal = c("ABIBAL", "PICGLA", "PICMAR")
    Pioneer = c("BETPAP", "POPTRE")

    # Perturbation types
    logging <- c("l", "lpr", "pl")
    outbreak <- c("o")
    burn <- c("b")
    # Specific color and scale for each perturbation type
    scale_fill_logging <- scale_fill_manual(values = 
                c("nonl" = "white","nonlpr" = "white","nonpl" = "white",
                "ouil" = "#fd9800","ouilpr" = "#09b33c","ouipl" = "#4981e0"))
    scale_color_logging <- scale_color_manual(values = c("l" = "#f49200", "lpr" = "#09b33c", "pl" = "#4981e0"))
    scale_x_logging <- scale_x_continuous(breaks=c(1,2,3),
                labels=c("10", "20", "30"), limits = c(0.7,3.3))
    scale_fill_outbreak <-  scale_fill_manual(values = 
            c("nono" = "white", "ouio" = "#0c0c61"))
    scale_color_outbreak <- scale_color_manual(values = c("o" = "#0c0c61"))
    scale_x_outbreak <- scale_x_continuous(breaks=c(1,2,3),
            labels=c("10", "20", "30"), limits = c(0.7,3.3))
    scale_fill_burn <- scale_fill_manual(values = 
                c("nonb" = "white", "ouib" = "#a11f1f"))
    scale_color_burn <- scale_color_manual(values = c("b" = "#a11f1f"))
    scale_x_burn <- scale_x_continuous(breaks=c(1,2,3),
                labels=c("50", "75", "100"), limits = c(0.7,3.3))


    # Diverse ggplot attribute to add to my graph :
    facets <-  facet_wrap(~ sp_code, nrow=1, 
        labeller = as_labeller(
            c("b" = "burn", "l" = "logging", "pl" = "partial_logging", "o" = "outbreak",
            "ACERUB" = "A. rubrum", "ACESAC" = "A. saccharum", 
            "BETALL" = "B. alleghaniensis", "BETPAP" = "B. papyrifera",
            "POPTRE" = "P. tremuloides", "ABIBAL" = "A. balsamea",
            "PICGLA" = "P. glauca", "PICMAR" = "P. mariana")))
    general_blanck_theme <- theme(
        legend.position = "none", axis.title.x = element_blank(),axis.title.y = element_blank(), axis.ticks.y = element_blank(), axis.text.y = element_blank(), strip.text.x = element_blank())
    zero_line <- geom_hline(yintercept = 0, linetype = "dashed", color = "red")
    limits = ylim(-a,a)

    ## PLOT CREATION
    #------------------

    for (p in c("logging", "outbreak", "burn")){
        for (sp_type in c("Temperate", "Boreal", "Pioneer")){

            plot <- 
                # core of the plot
                ggplot(df %>% filter(perturb %in% get(p), sp_code %in% get(sp_type))) +
                    geom_linerange(aes(x =  date_perturb, ymin = min, ymax = max, color = perturb)) +
                    geom_point(aes(x = date_perturb, y = mean, color = perturb, fill = paste0(significatif,perturb)),
                        shape = 21, size = 3, stroke = 1) +
                # general theme and add-ons
                    theme_bw() +
                    general_blanck_theme +
                    zero_line +
                    facets +
                    limits +
                # specific colors and x axis for each perturbation type
                    get(paste0("scale_fill_", p)) +
                    get(paste0("scale_color_", p)) +
                    get(paste0("scale_x_", p))

            ## Specific labels for each perturbation type 
            # to have name of species only once at the top of the graph
            if(p == "logging"){
                plot <- plot + 
                    labs(title = sp_type) + 
                    theme(strip.text.x = element_text(size = 10,color = "#656565",face = "italic"),strip.background = element_blank())}
            # to have the x axis only once at the bottom of the graph
            if(p == "burn" & sp_type == "Pioneer"){
                plot <- plot +
                    labs(x = "Time since disturbance (years)")
                    theme(axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")))}
            # Specific labels for each species (to have the x axis only once on the left of the total plot)
            if(sp_type == "Temperate"){
                plot <- plot +
                    labs(y = "estimate") +
                    theme(axis.title.y = element_text(angle = 90, margin = margin(t = 0, r = 10, b = 0, l = 0, unit = "pt")), axis.ticks.y = element_line(), axis.text.y = element_text())}

            assign(paste0("plot_", sp_type), plot)
        } # sp_type
        assign(paste0("plot_", p), plot_Temperate + plot_Pioneer + plot_Boreal + plot_layout(width = c(3,2,3)))
    } # perturb

    #Create the Legend for the plots
    df <- df %>% mutate(perturb = factor(perturb, levels = c("l","lpr","pl","o","b")))
    legend <- get_legend(ggplot(df) +
        geom_linerange(aes(x = date_perturb, y = mean,ymin = min, ymax = max, color = perturb)) +
        geom_point(aes(x = date_perturb, y = mean,color = perturb), shape = 21, size = 3, stroke = 1, fill = "white") +
        theme_bw() +
        scale_color_manual("Disturbances :", values = c("l" = "#f49200", "lpr" = "#09b33c", "pl" = "#4981e0",
        "b" ="#a11f1f", "o" = "#0c0c61"),
            labels = c("Clearcut", "CPRS", "Partial cut", "Outbreak", "Fire")) +
        theme(legend.text = element_text(size = 11),
            legend.title = element_text(size = 12),
            legend.position = "top"))

    return ((plot_logging / plot_outbreak / plot_burn / legend) + plot_layout(height = c(3,3,3,1)))
}
