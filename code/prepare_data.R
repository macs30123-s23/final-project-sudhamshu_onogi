
# Prepare data for adjacency list and twitter-users set
followers_list_file <- '/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/adj-list-C116.rdata'
twitter_users_file <- '/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/all-users-2019.rdata'
file_path <- '/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/all_actors/'
data <- read.csv('/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/data.csv')


files <- list.files(file_path)
follower_adj_list <- list()
not.in <- c()
all_twitter_users <- c()

pb <- txtProgressBar(min=1,max=nrow(data), style=3)
for (file in data$ODU.WSDL){
  if (file.exists(paste(file_path,file,'.txt', sep = ""))){
    temp = scan(paste(file_path,file,'.txt', sep = ""), what="", sep='\n')
    follower_adj_list[[file]] = temp
    all_twitter_users = union(all_twitter_users, temp)
  }else{
      not.in <- c(file,not.in)
  }

  setTxtProgressBar(pb, count+1)
}


# Save adjacency list

# saveRDS(follower_adj_list, file='adj-list-C116.rds')
# saveRDS(all_twitter_users, file='all-users-2019.rds')

# Create adjacency Matrix (subset)

all_twitter_users <- readRDS('/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/all-users-2019.rds')
follower_adj_list <- readRDS('/Users/sudhamshu.hosamane/Q5/plsc-40502-statistical-models/project/adj-list-C116.rds')

m <- length(follower_adj_list)
rows <- list()
columns <- list()
set.seed(60615)
# twitter_user_subset <- sample(all_twitter_users,10000000)
pb <- txtProgressBar(min=1,max=m, style=3)
for (j in 1:m){
  to_add <- which(all_twitter_users %in% follower_adj_list[[j]])
  rows[[j]] <- to_add
  columns[[j]] <- rep(j, length(to_add))
  setTxtProgressBar(pb, j)
}

rows <- unlist(rows)
columns <- unlist(columns)

# preparing sparse Matrix
library(Matrix)
y <- sparseMatrix(i=rows, j=columns)
rownames(y) <- all_twitter_users
colnames(y) <- names(follower_adj_list)


# saveRDS(y,'y_full.rds')


