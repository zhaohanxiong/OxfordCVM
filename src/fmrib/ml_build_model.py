import scipy.io
import numpy as np
import pandas as pd
import tensorflow as tf

# build keras model using tensorflow operations
class cTI_tf_layer(tf.keras.layers.Layer):

       # initialize object when an instance is run
       def __init__(self, pseudotimes_arr, ref_data, transform_mat):

              # create keras layer
              super(cTI_tf_layer, self).__init__()

              # initialize constants in model
              self.psuedo = tf.constant(pseudotimes_arr, dtype = tf.float32)
              self.ref_data = tf.constant(ref_data, dtype = tf.float32)
              self.transform_mat = tf.constant(transform_mat, dtype = tf.float32)

       # method to call class
       def call(self, data_in, K = 1):

              # input data is row of values for new patient (same number of cols as
              # ukb_mat which has been normalized using the ukb_mat mean and standard deviation) 
              # and K, the number of nearest neighbors to use

              # transform input data into PC space
              data_in_pc = tf.linalg.matmul(data_in, self.transform_mat)

              # perform row-wise euclidean distance calculation between input and ukb_mat
              diff = tf.math.abs(data_in_pc - self.ref_data)
              euc_dist = tf.math.reduce_sum(diff, axis = 1)

              # compute nearest neighbor
              top_k_ind = tf.argsort(euc_dist, direction = "ASCENDING")[0:K]
              inference_score = tf.reduce_mean(tf.gather(self.psuedo, top_k_ind))
              
              # add dimension as outputs need to have a tensor shape
              shaped_output = tf.expand_dims(inference_score, 0, name = "cTI_output")
              
              return shaped_output

# load disease scores as reference groups for neighrest neighbor
pseudotimes = pd.read_csv("NeuroPM/io/pseudotimes.csv", index_col = False)[
                                                        "global_pseudotimes"].to_numpy()

# load features and transformation matrix into principle component space
ukb_num = pd.read_csv("NeuroPM/io/ukb_num_norm.csv", index_col = False).fillna(0).to_numpy()
pc_transform = scipy.io.loadmat("NeuroPM/io/PC_Transform.mat")["Node_Weights"]

# transform data into PC space
ukb_pc = np.matmul(ukb_num, pc_transform)

# preprocess to remove rows which correspond to between group
# preprocess to remove rows which have ambiguous disease scores (overlap region)

# initialize tf model input layer
k_input = tf.keras.Input(shape = (ukb_num.shape[1]), name = "cTI_input")

# initialize cTI inference with keras layer
k_cTI_layer = cTI_tf_layer(pseudotimes, ukb_pc, pc_transform)(k_input)

# create keras model from keras layer
model = tf.keras.Model(k_input, k_cTI_layer)

# save model (get two versions ready for testing multi-config)
# must be in the format of /model/n/ for serving
model.save("../Deploy_ML/tf_serving_container/saved_models/1/")

print("Python -- Successfully Built and Packaged Model")
