import os
import sys
import mlflow
import shutil
import argparse

# set output directory
tf_serving_dir1 = "../../aws/tf_serving/saved_models/1/"
tf_serving_dir2 = "../../aws/tf_serving/saved_models/2/"

# set experiment ID
parser = argparse.ArgumentParser()
parser.add_argument("--experiment_id", default = "1", type = str, 
                                       help = "experiment ID")
args = parser.parse_args(sys.argv[1:])

# current latest version
ver = len(os.listdir("./mlruns/" + args.experiment_id))

# initialize mlflow session, this can be used for remote tracking too
mlflow.set_tracking_uri("http://localhost:5000") # can be aws s3 bucket link
mlflow.set_registry_uri("sqlite:///mlruns.db") # can be aws rds postgres link
mlflow.set_experiment("cti_predict")

# start mlflow session for tracking
with mlflow.start_run(run_name = "test run") as run:

    # retrieve table of logging info
    df = mlflow.search_runs(experiment_names = ["cti_predict"])
    df = df.loc[df["experiment_id"] == args.experiment_id]

    # obtain best model and its respective directory
    best_ver       = df['metrics.RMSE'].idxmin() + 3
    run_id         = df.loc[best_ver - 1]['run_id']
    best_model_dir = "./mlruns/" + args.experiment_id + "/" + \
                            run_id + "/artifacts/keras_models/data/model/"

    # connect to mlflow model registry
    client = mlflow.MlflowClient()
    model_info = client.search_model_versions("name='keras_cTI'")

    # update model version: Archived -> Staging -> Production
    # set all models to archived
    for i in range(ver):
        client.transition_model_version_stage(name    = "keras_cTI",
                                              version = i, 
                                              stage   = "Archived")
    
    # set best model to staging
    best_ver = ver - best_ver + 1
    client.transition_model_version_stage(name    = "keras_cTI",
                                          version = best_ver, 
                                          stage   = "Staging")

    # clean up tf-serving v2 directory
    shutil.rmtree(tf_serving_dir1)
    shutil.rmtree(tf_serving_dir2)
    
    # copy best model from mlflow/runs to tf-serving v2
    shutil.copytree(best_model_dir, tf_serving_dir1)
    shutil.copytree(best_model_dir, tf_serving_dir2)

print("Python -- Updated Latest Best Model for Deployment")
