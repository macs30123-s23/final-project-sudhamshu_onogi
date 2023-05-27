library(Matrix)
library(emIRT)
lout_temp <- readRDS('lout_final_temp9.rds')
y_final <- readRDS('y_3Mn_pp.rds')

alpha=lout_temp$means$alpha
beta=lout_temp$means$beta
w = lout_temp$means$w
theta = lout_temp$means$theta

data("ustweet")
netem_data_final <- ustweet
netem_data_final$starts$alpha = alpha
netem_data_final$starts$beta = beta
netem_data_final$starts$w = w
netem_data_final$starts$theta = theta

netem_data_final$data = as.matrix(y_final)

gc()

lout <- networkIRT(.y = netem_data_final$data,
                   .starts = netem_data_final$starts,
                   .priors = netem_data_final$priors,
                   .control = {list(verbose = TRUE,
                                    maxit = 3200,
                                    checkfreq = 50,
                                    convtype = 2,
                                    thresh = 1e-5,
                                    threads = 28
                   )
                   }
)

saveRDS(lout, 'lout_final_temp10.rds')
