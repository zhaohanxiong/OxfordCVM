import os
import sys
import mlflow
import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import tensorflow as tf

# set experiment ID
parser = argparse.ArgumentParser()
parser.add_argument("--experiment_id", default = "1", type = str, help = "experiment ID")
args = parser.parse_args(sys.argv[1:])

# current latest version
ver = len(os.listdir("./mlruns/" + args.experiment_id))

# define paths for i/o
path_model     = "./mlruns_staging/"
path_data      = "../../modelling/NeuroPM/io/"
path_data_val  = os.path.join(path_data, "ukb_num_norm_ft_select.csv")
path_data_pred = os.path.join(path_data, "inference_cTI_ml_pred.csv")

# load model
cTI_model = tf.keras.models.load_model(path_model)

# load data
ukb_df = pd.read_csv(path_data_val)
ml_inf = pd.read_csv(path_data_pred)

# initialize mlflow session, this can be used for remote tracking too
mlflow.set_tracking_uri("http://localhost:5000") # can be aws s3 bucket link
mlflow.set_registry_uri("sqlite:///mlruns.db") # can be aws rds postgres link
mlflow.set_experiment("cti_predict")

# start mlflow session for tracking
with mlflow.start_run(run_name = "test run") as run:

    # transform gt/pred into array
    gt   = ml_inf["score_gt"].to_numpy()
    pred = ml_inf["score_pred"].to_numpy()

    # evaluate accuracy of predictions against ground truths
    rmse = np.sqrt((gt - pred)**2)

    # evaluate by group
    bp_group = ml_inf["bp_group"].to_numpy()
    rmse_0 = np.mean(rmse[bp_group == 1])
    rmse_1 = np.mean(rmse[bp_group == 0])
    rmse_2 = np.mean(rmse[bp_group == 2])
    rmse = np.mean(rmse)

    # define model signatures 
    input_schema = mlflow.types.schema.Schema([
                        mlflow.types.schema.TensorSpec(np.dtype(np.float32), 
                                                       (-1, 1, ukb_df.shape[1]))])
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
    # automatic logging can also be performed:
    # https://www.mlflow.org/docs/latest/tracking.html#tensorflow-and-keras
    mlflow.set_tags({"experiment version": "0.0", "model flavour": "keras"})
    mlflow.log_metrics({"RMSE":            rmse,
                        "RMSE_background": rmse_0, 
                        "RMSE_between":    rmse_1,
                        "RMSE_disease":    rmse_2})
    mlflow.log_params({"n_rows": ml_inf.shape[0]})

    # store output visualization for results
    plot_path = "./mlruns/" + args.experiment_id + "/" + \
                                        run.info.run_id + "/artifacts/keras_models"
    
    plt = sns.boxplot(x = 'bp_group', y = 'score_gt', data = ml_inf)
    fig = plt.get_figure()
    fig.savefig(plot_path + "/disease score distribution.png")

print("Python -- Tracked Most Recent ML Model")
