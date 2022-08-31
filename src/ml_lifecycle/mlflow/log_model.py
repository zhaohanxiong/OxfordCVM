import os
import sys
import mlflow
import argparse
import numpy as np
import pandas as pd
import tensorflow as tf
import matplotlib.pyplot as plt

# current latest version
ver = len(os.listdir("./mlruns/1"))

# load model new model
cTI_model = tf.keras.models.load_model("../tf_serving/saved_models/2/")

# set random seed
parser = argparse.ArgumentParser()
parser.add_argument("--random_n", default = 100, type = int, help = "random N")
parser.add_argument("--random_seed", default = 1234, type = int, help = "random seed")
args = parser.parse_args(sys.argv[1:])

# load data & labels
test_sample = pd.read_csv("../../fmrib/NeuroPM/io/ukb_num_norm.csv").fillna(0)
test_sample = test_sample.sample(n = args.random_n, 
                                 random_state = args.random_seed).to_numpy()
test_label = pd.read_csv("../../fmrib/NeuroPM/io/pseudotimes.csv")
test_label = test_label.sample(n = args.random_n,
                               random_state = args.random_seed)

# initialize mlflow session, this can be used for remote tracking too
mlflow.set_tracking_uri("http://localhost:5000") # can be aws s3 bucket link
mlflow.set_registry_uri("sqlite:///mlruns.db") # can be aws rds postgres link
mlflow.set_experiment("cti_predict")

# start mlflow session for tracking
with mlflow.start_run(run_name = "test run"):

    # make inference for each row
    pred = []
    for i in range(test_sample.shape[0]):
        pred.append(cTI_model.predict(test_sample[None, i, :], verbose = 0)[0])

    # transform gt/pred into array
    gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)

    # evaluate accuracy of predictions against ground truths
    rmse = np.sqrt((gt - pred)**2)

    # evaluate by group
    bp_group = test_label["bp_group"].to_numpy()
    rmse_0 = np.mean(rmse[bp_group == 1])
    rmse_1 = np.mean(rmse[bp_group == 0])
    rmse_2 = np.mean(rmse[bp_group == 2])
    rmse = np.mean(rmse)

    # define model signatures 
    input_schema = mlflow.types.schema.Schema([
                        mlflow.types.schema.TensorSpec(np.dtype(np.float32), 
                                                       (-1, 1, test_sample.shape[1]))])
    output_schema = mlflow.types.schema.Schema([
                        mlflow.types.schema.TensorSpec(np.dtype(np.float32),
                                                       (-1, 1))])
    signature = mlflow.models.signature.ModelSignature(inputs = input_schema,
                                                       outputs = output_schema)
    
    # log model, also register model using ml-flow
    mlflow.keras.log_model(keras_model = cTI_model,
                           artifact_path = "keras_models", 
                           registered_model_name = "keras_cTI",
                           signature = signature)

    # log metric to mlflow server manually
    # automatic logging can also be performed: https://www.mlflow.org/docs/latest/tracking.html#tensorflow-and-keras
    mlflow.set_tags({"version": "0.0", "model": "keras"})
    mlflow.log_metrics({"RMSE": rmse, "RMSE_background": rmse_0, 
                        "RMSE_between": rmse_1, "RMSE_disease": rmse_2})
    mlflow.log_params({"n_rows": test_label.shape[0]})

    # update model stage: Staging, Production, Archived
    # achieve previous version and stage new model
    client = mlflow.MlflowClient()
    client.transition_model_version_stage(name = "keras_cTI", version = ver, 
                                          stage = "Archived")
    client.transition_model_version_stage(name = "keras_cTI", version = ver + 1, 
                                          stage = "Staging")

    # rename model name
    client.rename_registered_model(name = "keras_cTI", new_name = "keras_cTI")

    # update model version
    client.update_model_version(name = "keras_cTI", version = ver + 1,
                                description = "nereast neighbor cTI prediction")

    # delete model all versions & single version of model
    #client.delete_model_version(name = "registered_model_name", version = n)
    #client.delete_registered_model(name = "registered_model_name")
