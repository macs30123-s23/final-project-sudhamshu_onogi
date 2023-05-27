library(Matrix)
library(emIRT)
# y <- readRDS('/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/y_200K.rds')
# y_1Mn <- readRDS('/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/y_1Mn.rds')
y_final <- readRDS('y_3Mn_pp.rds')
data <- read.csv('data.csv')
data$startvalues[data$nominate_dim1<0]=-0.5
data$startvalues[data$nominate_dim1>0]=0.5

# colK <- colSums(y)
# rowJ <- rowSums(y)
# 
# colK_1Mn <- colSums(y_1Mn)
# rowJ_1Mn <- rowSums(y_1Mn)

colK_final <- colSums(y_final)
rowJ_final <- rowSums(y_final)

normalize <- function(x){ (x-mean(x))/sd(x) }

alpha=as.matrix(unname(normalize(log(colK_final+0.0001))))
beta=as.matrix(unname(normalize(log(rowJ_final+0.0001))))
w = as.matrix(data$startvalues)
theta = as.matrix(rnorm(length(rowJ_final)))

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
                                    maxit = 2000,
                                    checkfreq = 10,
                                    convtype = 2,
                                    thresh = 1e-5,
                                    threads = 28
                   )
                   }
)

saveRDS(lout, 'lout_final_2K.rds')
