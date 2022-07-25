import pandas as pd
import tensorflow as tf

# build keras model using tensorflow operations
class cTI_tf_layer(tf.keras.layers.Layer):

       # initialize object when an instance is run
       def __init__(self, ukb_vars_mat, pseudotimes_arr):

              # create keras layer
              super(cTI_tf_layer, self).__init__()

              # initialize constants in model
              self.ukb_mat = tf.constant(ukb_vars_mat, dtype = tf.float32)
              self.psuedo = tf.constant(pseudotimes_arr, dtype = tf.float32)

       # method to call class
       def call(self, data_in, K = 3):

              # input data is row of values for new patient (same number of cols as
              # ukb_mat) and K, the number of nearest neighbors to use

              # perform row-wise euclidean distance calculation between input and ukb_mat
              diff = tf.math.abs(data_in - self.ukb_mat)
              euc_dist = tf.math.reduce_sum(diff, axis = 1)

              # compute nearest neighbor
              top_k_ind = tf.argsort(euc_dist, direction = "ASCENDING")[0:K]
              inference_score = tf.reduce_mean(tf.gather(self.psuedo, top_k_ind))
              
              # add dimension as outputs need to have a tensor shape
              shaped_output = tf.expand_dims(inference_score, 0, name = "cTI_output")
              
              return shaped_output

# load dataframes as model parameters
pseudotimes = pd.read_csv("NeuroPM/io/pseudotimes.csv", index_col = False)[
                                                        "global_pseudotimes"].to_numpy()
ukb_num = pd.read_csv("NeuroPM/io/ukb_num.csv", index_col = False).fillna(0).to_numpy()

# initialize input layer
k_input = tf.keras.Input(shape = (ukb_num.shape[1]), name = "cTI_input")

# initialize cTI inference with keras layer
k_cTI_layer = cTI_tf_layer(ukb_num, pseudotimes)(k_input)

# create keras model from keras layer
model = tf.keras.Model(k_input, k_cTI_layer)

# save model (get two versions ready for testing multi-config)
# must be in the format of /model/n/ for serving
model.save("../Deploy_ML/tf_serving_container/saved_models/1/")

print("Python -- Successfully Built and Packaged Model")
