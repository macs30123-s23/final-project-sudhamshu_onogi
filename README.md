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

1. **Data Collection**: Twitter follower network data for 535 members of the 116th Congress and their Twitter followers is collected from sources 
   described in the [report](./macs30123_paper_final.pdf). This data 
   includes information about the relationships between the politicians and their followers.
2. Preprocessing: The collected data is preprocessed to extract relevant information from multiple datasets ([data](./data)) and create a suitable 
   representation for further analysis. This includes cleaning the data, handling missing values, and transforming the data into a suitable format for analysis.
3. Bayesian Ideal Point Estimation Model: A Bayesian Ideal Point Estimation model is employed to estimate the ideological positions of politicians 
   and Twitter followers. This model takes into account the network structure and content-consumption information to estimate ideological leanings.
4. Scalable Computing: The estimation process is performed using scalable computing methods to handle the large-scale Twitter follower network data. 
   Distributed computing frameworks such as Apache Spark are utilized to efficiently process and analyze the data.
5. Evaluation and Interpretation: The estimated ideological positions are evaluated and interpreted to gain insights into political behavior and 
   policy outcomes. Various metrics and visualizations are used to understand the distribution of ideology and identify patterns and trends.

### Model
We 

### Data
I identified the legislators of the 116th U.S Congress as the Twitter elites for my study. The 116th Congress had
• 100 senators, two from each of the fifty states.
• 435 representatives, seats are distributed by population across the fifty states.
• 6 non-voting members from the District of Columbia and US territories which include American Samoa, Guam, Northern Mariana Islands, Puerto Rico, and US Virgin Islands.
Rauhauser (2019b), Rauhauser (2019a) assimilated a directory of files in 2019 that contains followers (as Twitter IDs) corresponding to each Twitter handle (which is the name of each file). Apart from Official (Office) Twitter handles, these folders also contained handles (along with the list of followers) for several legislators’ campaign and personal Twitter accounts. To ensure that I only retrieved information for handles corresponding to official accounts, I used the official CSPAN twitter handle dataset curated by Siddique (2019), and retrieved the list of followers for this subset and stored thenetwork as an adjacency list (of directed edges from legislators to all their unique followers). This resulted in a total of 535 legislators with 6 missing in all - Rep. Collin Peterson (@collinpeterson), Rep. Greg Gianforte (@GregForMontana), and Delegate Gregorio Sablan (@Kilili_Sablan), Sen. Rick Scott (@SenRickScott), and Delegate Michael San Nicolas (No Twitter account). Since some Twitter elites also followed each other, to build a bipartite network I retrieved the Twitter IDs of all 535 legislators using the dataset collected by Wrubel and Kerchner (2020) and removed these IDs from the follower lists. To compare my final Twitter ideal point estimates to expert ratings, I mapped each of the twitter elite to their DW-NOMINATE scores, published by Voteview (J. B. Lewis et al. 2023). The total number of unique twitter users (followers) with this subset of elites were 16,420,157. These followers ranged from following only 1 Twitter elite to all 535 Twitter elites. Users who followed too few or too many legislators would not provide much information about the ideology of themselves or the elites they are following. To mitigate this issue, I removed all users who followed less than 3 or more than 300 legislators. This subset the final set of Twitter followers to 3,962,197 people. I sampled 3,000,000 users from this subset (uniformly random) to create a final adjacency matrix (of directed edges from oridnary users to elites) of size [3,000,000 × 535] (Users × Legislators) .

### Method
Bayesian Inference – Try 1 
We used RStan to run NUTS (auto-tuned HMC) on a random subset of (100K) users. It did not converge even after 20 hours. We tried the author's approach of getting starting values using NUTS and then running MCMC. The MCMC took too long to converge. We used the RMpi MPI wrapper for R with 28 processes (one per node), each sampling from 1 MCMC chain independently.Switched to the EM approach (Kosuke Imai et al., 2016). Formulate Joint posterior as posterior MLE with penalized prior.

Bayesian Inference – Try 2 – Using EM
We used the ‘emIRT’ R package (Kosuke Imai et al., 2016). We ran 5000 total iterations; took us about ~50 hours. 1000 iterations per run; hasn't converged (threshold 1e-6); but low rate of change of estimates between 4000th and 5000th iteration. We were still able to perform useful analysis. Estimation and inference of parameters for a dataset with 3,000,000 users took 50 hours and 15 Mins with 28 processes (Ran on RCC with 28 cores and 8GB memory) 

### Results and Validation
The above figure compares wj s, the ideal point estimates, of 535 members of the 116th US Congress based on their Twitter network of followers (x-axis) with their DW-NOMINATE scores based on their roll call voting records (Poole and Rosenthal 1999), on the y-axis. We can see that the estimated ideal points are clustered into two different groups that align almost perfectly with party membership. The correlation between Twitter and roll-call-based ideal points is 0.914 in the House and 0.936 in the Senate. This is comparable with the Twitter estimates for the 112th Congress (ρ = 0.941 in the House and 0.954 in the Senate) estimated in (Barberá 2015) using MCMC sampling. The correlation between Twitter estimates and DW-NOMINATE scores for Senate-Democrats, Senate-Republicans, House-Democrats and House-Republicans are 0.519, 0.573, 0.111 and 0.369 respectively.


