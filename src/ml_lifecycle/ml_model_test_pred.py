import os
import numpy as np
import pandas as pd
import tensorflow as tf

# define paths for i/o
path_model     = "../aws/tf_serving/saved_models/2/"
path_data      = "../fmrib/NeuroPM/io/"
path_data_val  = os.path.join(path_data, "ukb_num_norm_ft_select.csv")
path_data_lab  = os.path.join(path_data, "pseudotimes.csv")
path_data_pred = os.path.join(path_data, "inference_cTI_ml_pred.csv")

# load model
cTI_model = tf.keras.models.load_model(path_model)

# load test data
test_sample = pd.read_csv(path_data_val)
test_sample = test_sample.fillna(0)
test_sample = test_sample.sample(n = 10, random_state = 1).to_numpy()

# load labels
test_label = pd.read_csv(path_data_lab)
test_label = test_label.sample(n = 10, random_state = 1)

# Action
# make inference for each row of data
pred = []
for i in range(test_sample.shape[0]):
    pred.append(cTI_model.predict(test_sample[None, i, :], verbose = 0)[0])

gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)

# write to output
pandas_out_dict = {"score_pred": pred,
                   "score_gt":   gt,
                   "bp_group":   test_label["bp_group"]}
pd.DataFrame(pandas_out_dict).to_csv(path_data_pred, index = False)
