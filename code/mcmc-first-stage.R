
# loading data (adjacency matrix)
y_final <- readRDS('y_3Mn_pp.rds')

## starting values for elites (for identification purposes)
data <- read.csv('data.csv')

# parameters for Stan model
n.iter <- 500
n.warmup <- 100
thin <- 2 ## this will give up to 200 effective samples for each chain and par

# Set starting values for legislator ideologies
start.phi <- rep(1, length(data)) #set default starting value to 1 for everyone (right leaning)
start.phi[which(data$party_code == 100)] <- -1 # set starting values for democrats to -1

## data for model

J <- ncols(y_final)
K <- nrows(y_final)
N <- J * K
jj <- rep(1:J, times=K)
kk <- rep(1:K, each=J)

stan.data <- list(J=J, K=K, N=N, jj=jj, kk=kk, y=c(as.matrix(y)))

## rest of starting values
colK <- colSums(y_final)
rowJ <- rowSums(y_final)
normalize <- function(x){ (x-mean(x))/sd(x) }

inits <- rep(list(list(alpha=normalize(log(colK+0.0001)), 
	beta=normalize(log(rowJ+0.0001)),
  theta=rnorm(J), phi=start.phi,mu_beta=0, sigma_beta=1, 
  gamma=abs(rnorm(1)), mu_phi=0, sigma_phi=1, sigma_alpha=1)),2)


library(rstan)

stan.code <- '
data {
  int<lower=1> J; // number of twitter users
  int<lower=1> K; // number of elite twitter accounts
  int<lower=1> N; // N = J x K
  int<lower=1,upper=J> jj[N]; // twitter user for observation n
  int<lower=1,upper=K> kk[N]; // elite account for observation n
  int<lower=0,upper=1> y[N]; // dummy if user i follows elite j
}
parameters {
  vector[K] alpha;
  vector[K] phi;
  vector[J] theta;
  vector[J] beta;
  real mu_beta;
  real<lower=0.1> sigma_beta;
  real mu_phi;
  real<lower=0.1> sigma_phi;
  real<lower=0.1> sigma_alpha;
  real gamma;
}
model {
  alpha ~ normal(0, sigma_alpha);
  beta ~ normal(mu_beta, sigma_beta);
  phi ~ normal(mu_phi, sigma_phi);
  theta ~ normal(0, 1); 
  for (n in 1:N)
    y[n] ~ bernoulli_logit( alpha[kk[n]] + beta[jj[n]] - 
      gamma * square( theta[jj[n]] - phi[kk[n]] ) );
}
'

## compiling model
stan.model <- stan(model_code=stan.code, 
    data = stan.data, inits=inits, iter=1, warmup=0, chains=1)

## running model
stan.fit <- stan(fit=stan.model, data = stan.data, 
	iter=n.iter, warmup=n.warmup, chains=2, 
  	thin=thin, inits=inits)

save(stan.fit, file='stan_fit.rdata')

## extracting and saving sampled points
samples <- extract(stan.fit, pars=c("alpha", "phi", "gamma", "mu_beta",
	"sigma_beta", "sigma_alpha"))
save(samples, file='first_stage_samples.rdata')

## saving estimates from samples
results <- data.frame(
	screen_name = samples$m.names,
	phi = apply(samples$phi, 2, mean),
	phi.sd = apply(samples$phi, 2, sd),
	alpha = apply(samples$alpha, 2, mean),
	alpha.sd = apply(samples$alpha, 2, sd),
	stringsAsFactors=F)
save(results, file='estimates_elite.rdata')








