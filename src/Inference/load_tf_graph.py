import os
import pandas as pd
import tensorflow.compat.v1 as tf

# set path
path = "IG"
os.chdir(path)

# disable tensorflow 2 behaviour
tf.disable_v2_behavior()

# We load the protobuf file andretrieve the unserialized graph_def
with tf.gfile.GFile("frozen_model.pb", "rb") as f:
       graph_def = tf.GraphDef()
       graph_def.ParseFromString(f.read())

# Then, we import the graph_def into a new Graph and returns it 
with tf.Graph().as_default() as graph:
       # The name var will prefix every op/nodes in your graph
       # Since we load everything in a new graph, this is not needed
       tf.import_graph_def(graph_def, name = "prefix")

# access the input and output nodes
data_in = graph.get_tensor_by_name('prefix/input:0')
data_out = graph.get_tensor_by_name('prefix/output:0')

# run test case
if False:
       # load test data
       sample = pd.read_csv("../sample_disease.csv").fillna(0).to_numpy()

       # create session and make inference using our loaded parameters
       with tf.Session(graph = graph) as sess:
              y_out = sess.run(data_out, feed_dict = {data_in: sample})
              print(y_out)
