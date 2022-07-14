import os
import numpy as np
import pandas as pd
import tensorflow.compat.v1 as tf

# set path
path = "NeuroPM/io/" # "src/fmrib/NeuroPM/io/" (vscode debug)
os.chdir(path)

# load dataframes as model parameters
pseudotimes = pd.read_csv("pseudotimes.csv", index_col = False)
ukb_num = pd.read_csv("ukb_num.csv", index_col = False).fillna(0)

# disable tensorflow 2 behaviour as we are still using tf 1
tf.disable_v2_behavior()

# build tensorflow model
graph = tf.Graph()
with graph.as_default() as g:

       # define input placeholder
       data_in = tf.placeholder(dtype = tf.float32, shape = (1, ukb_num.shape[1]),
                               name = "input")

       # define 
       ukb_mat = tf.constant(ukb_num.to_numpy(), dtype = tf.float32)
       pseudo = tf.constant(pseudotimes["global_pseudotimes"].to_numpy(), dtype = tf.float32)

       # perform row-wise euclidean distance calculation between input and ukb_mat
       diff = tf.math.abs(data_in - ukb_mat)
       euc_dist = tf.math.reduce_sum(diff, axis = 1)

       # compute nearest neighbor
       K = 3
       top_k_ind = tf.argsort(euc_dist, direction = "ASCENDING")[0:K]
       inference_score = tf.reduce_mean(tf.gather(pseudo, top_k_ind),
                                        name = "output")

         
# run session to test and write graph to file
with tf.Session(graph = graph) as sess:

       # initialize computational graph
       initialize = tf.global_variables_initializer()
       sess.run(initialize)

       # list output nodes
       output_node_names = [n.name for n in tf.get_default_graph().as_graph_def().node]

       # freeze graph by converting all variables to constants
       output_graph_def = tf.graph_util.convert_variables_to_constants(
                                   sess,
                                   tf.get_default_graph().as_graph_def(),
                                   output_node_names)

       # serialize and dump the output graph to output directory
       with tf.gfile.GFile("../../../Inference/IG/frozen_model.pb", "wb") as f:
              f.write(output_graph_def.SerializeToString())

       # run test case
       if False:
              # test samples, these are assuming ukb_mat has 1082 columns (update test data if it changes)
              sample = pd.read_csv("sample_test_data/sample_disease.csv").fillna(0).to_numpy()

              # feed data into input and obtain output from session
              pred = sess.run(inference_score, feed_dict = {data_in: sample})
              print(pred)
