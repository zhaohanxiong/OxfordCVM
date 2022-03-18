import os
import sys
import numpy as np
import pandas as pd

df = pd.read_csv("bb_data.csv")

sys.pause()

# 0) preprocessing to adjust for covariates
# 1) keep feature with high ratio of local vs global variance
#    which correspond to higher probability of being in 
#    trajectory
# 2) use cPCA which focuses more on diseased population
#    by using 2 covariant matrices to get a weighted difference
#    between the matrices. also uses multiple weightings 
#    and clusters them based on proximity to princical angle
#    to reduce to few subspaces. instead of visual inspection
#    in original algorithm, use gap clustering criteria (matlab)
# 2.1) main purpose of PCA is to reduce high dimensional data
#      down into 2 basic components, and highly correlated variables
#      cluster together in the 2D PCA representation. Distances
#      between each PC is also more significant for 1st component
#      compared to 2nd component.
# 2.2) PCA identifies direction with the highest variance in target
#      data, while cPCA identifies direction with highest variance
#      in the target data compared to background data
# 3) order subjects according to their proximity to background
#    population in the cPCA space. Get euclidean distance matrix
#    for all subjects and get the minimum spanning tree (minimum
#    distance path) from any subject to the background samples.
#    Then this can be used for every subject to calculate a score
#    using the shortest distance to the background sample's centroid
#    Lastly every subject is ordered according to these values.