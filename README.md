# Estimating Political Ideology using (massive) Social Network Data
Sudhamshu Hosamane and Koichi Onogi

## Introduction
This project focuses on estimating political ideology using Twitter follower network data. Political ideology plays a crucial role in shaping policy decisions and electoral outcomes, making it essential for understanding political behavior and policy outcomes. However, operationalizing policy positions has been a challenging task in the field of social science research.

Traditionally, researchers have relied on qualitative methods such as analyzing congressional voting records, speeches, and interviews to estimate ideology. While these methods provide valuable insights, they are resource-intensive, prone to errors, and not easily scalable to a wider audience.

To overcome these limitations, this project employs scalable computing methods to estimate political ideology. By leveraging Twitter follower network data for 535 members of the 116th Congress and their Twitter followers (approximately 3,000,000 users), a Bayesian Ideal Point Estimation model is utilized to estimate ideological positions.

## Problem justification
Estimating political ideology is of great importance for both voters and politicians. For voters, understanding the ideological leanings of politicians helps in making informed decisions at the ballot box. Voters are more likely to support candidates whose policy positions align with their own beliefs. By estimating the ideological leanings of politicians, voters can make informed decisions about which candidate to support and which policies to advocate for.

Similarly, for politicians, knowing the ideological leanings of their constituents is crucial. By understanding the preferences and priorities of their voters, politicians can tailor their policies and campaign messages to appeal to their base and build support for their platform.

While qualitative methods have been traditionally used for estimating ideology, they are limited in scalability and accuracy. The advancement of scalable computing methods offers an opportunity to overcome these limitations and provide more accurate and scalable estimates of political ideology.

## Large-Scale computing methods
This project utilizes large-scale computing methods to estimate political ideology using Twitter follower network data. The process involves the following steps:

1. **Data Collection**: Twitter follower network data for 535 members of the 116th Congress and their Twitter followers is collected from sources described in the [report](./macs30123_paper_final.pdf). This data includes information about the relationships between the politicians and their followers.
2. **Preprocessing**: The collected data is preprocessed to extract relevant information from multiple datasets ([data](./data)) and create a final dataset. The code for preprocessing is available in [clean_data.ipynb](./data/clean_data.ipynb). This includes cleaning the data, handling missing values, and merging data from mulitple datasets. We also created an adjacency matrix R object from the dataset using the code in [prepare_data.R](./code/prepare_data.R)
3. **Bayesian Ideal Point Estimation Model**: A Bayesian Ideal Point Estimation model is employed to estimate the ideological positions of politicians and Twitter followers. This model takes into account the network structure and content-consumption information to estimate ideological leanings.
4. Scalable Computing: The estimation process is performed using scalable computing methods to handle the large-scale Twitter follower network data. Distributed computing frameworks such as MPI (using a wrapper for R) are utilized to efficiently process and analyze the data.
5. Evaluation and Interpretation: The estimated ideological positions are evaluated and interpreted to gain insights into political behavior and  policy outcomes. Various metrics and visualizations are used to understand the distribution of ideology and identify patterns and trends. These are available in the [final report](./macs30123_paper_final.pdf)

### Model
We use a Bayesian Latent space model to estimate the ideologies for 535 members of the 116th Congress and also for a randomly selected sample of 3,000,000 users. We primarily estimate 4 latent variables  - $\alpha_i, \phi_i$ (latent variables for popularity of the legislator and their ideology respectively) and $\beta_j, theta_j$ for political interest and ideology estimate of regular Twitter user J. More details can be found in the report.

### Data
We used 3 datasets to merge relevant data and create a final dataset. More detailed description is inside the report.

### Method
We tried 2 methods to infer the estimates of interest.

First, we followed the original method of estimating the latent variables from [Berbera, 2015](birds-of-the-same-feather-tweet-together-bayesian-ideal-point-estimation-using-twitter-data.pdf). We first got an initial estimate (not converged) of $\phi$s and $\alpha$s using a No U Turn Sampler implemented in RStan. We used these as the starting values to sample more data using the Metropolis-Hastings algorithm for MCMC run using MPI on mulitple processes. The MCMC took too long to converge. We used the RMpi MPI wrapper for R with 28 processes (one per node), each sampling from 1 MCMC chain independently. We hoped to run smaller iterations (2000) on different processes and aggregate the results. The convergence was very slow (hadn't converged even after 20 hours) and we often saw the process kill itself due to lack of resources. We decided to switch to a more optimised algorithm rather than use more computing resources.


We used a variational Inference algorithm developed by [Kosuke Imai et al., 2016](./fastideal.pdf) available in the ‘emIRT’ R package. We ran 5000 total iterations; took us about ~50 hours. 1000 iterations per run; hasn't converged (threshold 1e-5); but low rate of change of estimates between 4000th and 5000th iteration. We were still able to perform useful analysis. Estimation and parallel inference of parameters using the EM algorithm for a dataset with 3,000,000 users took 50 hours and 15 Mins with 28 processes (Ran on midway 2 with 28 cores and 56GB of memory)

### Responsibilities

Sudhamshu Hosamane - Helped with the data collection, creation of adjacency matrix, the first-stage code using RStan, coding of the MPI code in R, and visualisations

Koichi Onogi - Helped with the creation of the final dataset by merging mulitple individual datasets, coding of the HM MCMC algorithm (second stage), coding and debugging the RMpi code and writing the report.




