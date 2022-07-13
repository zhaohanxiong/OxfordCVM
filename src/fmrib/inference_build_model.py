import os
import numpy as np
import pandas as pd
import tensorflow as tf

# set path
path = "NeuroPM/io/" # "src/fmrib/NeuroPM/io/" (vscode debug)
os.chdir("src/fmrib/NeuroPM/io/")

# load dataframes as model parameters
pseudotimes = pd.read_csv("pseudotimes.csv", index_col = False)
ukb_num = pd.read_csv("ukb_num.csv", index_col = False).fillna(0)

# build tensorflow model
graph = tf.Graph()
with graph.as_default() as g:

       # define settings for tensorflow 1 converting to 2 migration
       tf.compat.v1.disable_eager_execution()

       # define input placeholder
       data_in = tf.compat.v1.placeholder(dtype = tf.float32, shape = (1, ukb_num.shape[1]))

       # define 
       ukb_mat = tf.constant(ukb_num.to_numpy(), dtype = tf.float32)
       pseudo = tf.constant(pseudotimes["global_pseudotimes"].to_numpy(), dtype = tf.float32)

       # perform row-wise euclidean distance calculation between input and ukb_mat
       diff = tf.math.abs(data_in - ukb_mat)
       euc_dist = tf.math.reduce_sum(diff, axis = 1)

       # compute nearest neighbor
       K = 3
       top_k_ind = tf.argsort(euc_dist, direction = "ASCENDING")[0:K]
       inference_score = tf.reduce_mean(tf.gather(pseudo, top_k_ind))

# test samples, these are assuming ukb_mat has 1082 columns (update test data if it changes)
sample = pd.read_csv("sample_test_data/sample_disease.csv").fillna(0).to_numpy()

# run session
with tf.compat.v1.Session(graph = graph) as sess:

       # initialize computational graph
       initialize = tf.compat.v1.global_variables_initializer()
       sess.run(initialize)

       # write computational graph to file
       

       # test: feed data through computational graph and produce output
       pred = sess.run(inference_score, feed_dict = {data_in: sample})
       print(pred)
