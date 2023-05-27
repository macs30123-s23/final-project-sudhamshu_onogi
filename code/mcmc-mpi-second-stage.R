library(rstan)
library(Rmpi)

matrixfile <- 'y_3Mn_pp.rds'
samplesfile <- 'first_stage_samples.rdata'

## starting values for elites (for identification purposes)
data <- read.csv('data.csv')

if (!is.loaded("MPI_Init")) {
  stop("MPI_Init() not loaded. Please run the code using 'mpirun -np <num_processes> Rscript <script_name.R>'")
}
# Function to compute log posterior density
lpd <- function(alpha, beta, gamma, theta, phi, mu_beta, sigma_beta, y) {
  require(arm, quiet=TRUE)
  value <- alpha + beta - gamma * (theta - phi)^2
  sum(log(invlogit(value)^y * (1 - invlogit(value))^(1 - y))) +
    dnorm(theta, 0, 1, log = TRUE) + dnorm(beta, mean = mu_beta, sd = sigma_beta, log = TRUE)
}

# Function for Metropolis algorithm to compute ideology for an ordinary user
metropolis.logit <- function(y, alpha.i, gamma.i, phi.i, mu_beta.i, sigma_beta.i, beta.init, theta.init,
                             iters = 2000, delta = 0.05, chains = 2, n.warmup = 1000, thin = 1, verbose = FALSE) {
  
  # Preparing vector for stored samples
  keep <- seq(n.warmup + 1, iters, by = thin)
  pars.samples <- array(NA, dim = c(length(keep), chains, 2),
                        dimnames = list(NULL, NULL, c("beta", "theta")))
  
  # Preparing iterations from other parameters
  alpha.it <- apply(alpha.i, 2, function(x) matrix(x, nrow = iters, ncol = 1))
  phi.it <- apply(phi.i, 2, function(x) matrix(x, nrow = iters, ncol = 1))
  gamma.it <- matrix(gamma.i, nrow = iters, ncol = 1)
  mu_beta.it <- matrix(mu_beta.i, nrow = iters, ncol = 1)
  sigma_beta.it <- matrix(sigma_beta.i, nrow = iters, ncol = 1)
  
  # Iterations of the Metropolis algorithm
  for (chain in 1:chains) {
    # Drawing starting points
    pars.cur <- c(beta.init, theta.init[chain])
    i <- 1
    
    # Iterations
    for (iter in 1:iters) {
      # Getting samples from iterations
      alpha <- alpha.it[iter, ]
      gamma <- gamma.it[iter]
      phi <- phi.it[iter, ]
      mu_beta <- mu_beta.it[iter]
      sigma_beta <- sigma_beta.it[iter]
      
      # Sampling candidate values
      pars.cand <- sapply(pars.cur, function(x) runif(n = 1, min = x - delta, max = x + delta))
      
      # Computing acceptance probability
      accept.prob <- exp(lpd(alpha, beta = pars.cand[1], gamma, theta = pars.cand[2], phi, mu_beta, sigma_beta, y) -
                           lpd(alpha, beta = pars.cur[1], gamma, theta = pars.cur[2], phi, mu_beta, sigma_beta, y))
      
      alpha <- min(accept.prob, 1)
      
      # Jumping with probability alpha
      if (runif(1) <= alpha) {
        pars.cur <- pars.cand
      }
      
      # Storing samples
      if (iter %in% keep) {
        pars.samples[i, chain, ] <- pars.cur
        i <- i + 1
      }
    }
  }
  
  # Reporting summary statistics
  results <- round(monitor(pars.samples), 2)
  
  if (verbose == TRUE) {
    print(results)
    cat(chains, "chains, keeping last", length(keep),
        "iterations out of", iters, "\n")
  }
  
  return(list(samples = pars.samples, Rhat = results[, "Rhat"], n.eff = results[, "n.eff"]))
}

# Function for parallelized version of metropolis algorithm
estimation <- function(first, last = first + 4999, num_iterations, delta, chains, n.warmup, thin, verbose) {
  pars <- first:last
  beta.samples <- array(NA, dim = c(length(pars), 200),
                        dimnames = list(paste("beta[", first:last, "]", sep = ""),
                                        paste("Iteration ", 1:200, sep = "")))
  theta.samples <- array(NA, dim = c(length(pars), 200),
                         dimnames = list(paste("theta[", first:last, "]", sep = ""),
                                         paste("Iteration ", 1:200, sep = "")))
  theta.results <- data.frame(theta = NA,
                              id = dimnames(y)[[1]][1:length(pars)], rhat = NA, n.eff = NA,
                              stringsAsFactors = FALSE)
  
  for (i in 1:length(pars)) {
    fit <- metropolis.logit(y[pars[i], ], alpha.i, gamma.i, phi.i, mu_beta.i, sigma_beta.i,
                            beta.init = log(sum(y[pars[i], ])), theta.init = rnorm(2, 0, 1), iters = num_iterations,
                            delta = delta, chains = chains, n.warmup = n.warmup, thin = thin, verbose = verbose)
    
    if (fit$Rhat[2] > 1.05) {
      fit <- metropolis.logit(y[pars[i], ], alpha.i, gamma.i, phi.i, mu_beta.i, sigma_beta.i,
                              beta.init = log(sum(y[pars[i], ])), theta.init = rnorm(2, 0, 1),
                              iters = num_iterations * 2, delta = delta, chains = chains,
                              n.warmup = n.warmup * 2, thin = thin * 2, verbose = verbose)
    }
    
    beta.samples[i, ] <- c(fit$samples[, , "beta"])
    theta.samples[i, ] <- c(fit$samples[, , "theta"])
    theta.results$theta[i] <- mean(theta.samples[i, ])
    theta.results$rhat[i] <- fit$Rhat[2]
    theta.results$n.eff[i] <- fit$n.eff[2]
    cat(pars[i], "\n")
  }
  
  return(list(beta.samples = beta.samples, theta.samples = theta.samples,
              theta.results = theta.results))
}

# loading results of first stage
load(samplesfile)
alpha.i <- samples$alpha
gamma.i <- samples$gamma
phi.i <- samples$phi
mu_beta.i <- samples$mu_beta
sigma_beta.i <- samples$sigma_beta

# loading data matrix
load(matrixfile)

# Define the number of MCMC iterations and other parameters. The process did not converge for any reasonable number of iterations
num_iterations <- 3000
delta <- 0.15
num_chains <- mpi.universe.size() - 1
n.warmup <- 1000
thin <- 20
verbose <- TRUE

# Run the estimation for the desired range of users
n1 <- 1
n2 <- 100
y <- y[n1:n2, ]

# Initialize MPI processes
mpi.barrier()
if (mpi.comm.rank() == 0) {
  # Master process
  result <- estimation(n1, n2, num_iterations, delta, num_chains, n.warmup, thin, verbose)
} else {
  # Worker processes
  while (TRUE) {
    request <- mpi.recv(source = 0, tag = 1)
    if (request == "exit") {
      break
    }
    
    result <- estimation(request$first, request$last, num_iterations, delta, num_chains,
                         n.warmup, thin, verbose)
    mpi.send(result, dest = 0, tag = 2)
  }
}

# Finalize MPI processes
mpi.barrier()
if (mpi.comm.rank() == 0) {
  # Master process
  # Receive results from worker processes
  for (i in 1:(mpi.universe.size() - 1)) {
    result <- mpi.recv(source = i, tag = 2)
  }
}

# Save results
if (mpi.comm.rank() == 0) {
  save(result, file = "outputfile.RData")
}
mpi.exit()
