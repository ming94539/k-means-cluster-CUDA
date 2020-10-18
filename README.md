# k-means-cluster-CUDA
Implementation of K Means Clustering in CUDA (Parallel Processing on GPU)

## Abstract
K-means clustering is a famous and ubiquitously used Machine Learning algorithm, and a type of unsupervised learning to cluster information based on latent structured information presented within the data. The goal of k-means is to find different clusters in the data with the number of groups represented by K.

However, as the number of data points, clusters, and iterations increases, the run time increases exponentially which serves as a bottleneck in the algorithm’s performance. This work shows how dramatically time complexity of K means algorithm can be reduced by taking advantage of steps that can be parallelized; while comparing and analyzing different serial and parallel implementations of K means algorithm, the paper will dive into parallel implementations that leverages GPU architecture and parallelization of ”Embarrassingly Parallel” tasks for better performance.

See more details in final_k_means_paper.pdf
