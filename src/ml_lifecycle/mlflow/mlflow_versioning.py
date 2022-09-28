import os
import sys
import mlflow
import argparse

# set experiment ID
parser = argparse.ArgumentParser()
parser.add_argument("--experiment_id", default = "1", type = str, help = "experiment ID")
args = parser.parse_args(sys.argv[1:])

# current latest version
ver = len(os.listdir("./mlruns/" + args.experiment_id))

# initialize mlflow session, this can be used for remote tracking too
mlflow.set_tracking_uri("http://localhost:5000") # can be aws s3 bucket link
mlflow.set_registry_uri("sqlite:///mlruns.db") # can be aws rds postgres link
mlflow.set_experiment("cti_predict")

# start mlflow session for tracking
with mlflow.start_run(run_name = "test run") as run:

    # update model stage: Staging, Production, Archived
# TO DO, THIS IS WRONG AND INCOMPLETE
    client = mlflow.MlflowClient()
    if ver > 0:
        client.transition_model_version_stage(name = "keras_cTI", version = ver, 
                                              stage = "Archived")

    client.transition_model_version_stage(name = "keras_cTI", version = ver + 1, 
                                        stage = "Staging")

    # store current best model into tf-serving directory for deployment
    df = mlflow.search_runs(experiment_names = ["cti_predict"])
    run_id = df.loc[df['metrics.RMSE'].idxmin()]['run_id']
    best_model_dir = "./mlruns/" + args.experiment_id + "/" + run_id + "/data/model/"

    # rename model name
    client.rename_registered_model(name = "keras_cTI", new_name = "keras_cTI")

    # update model version
    client.update_model_version(name = "keras_cTI", version = ver + 1,
                                description = "nereast neighbor cTI prediction")

    # delete model all versions & single version of model
    client.delete_model_version(name = "registered_model_name", version = n)
    client.delete_registered_model(name = "registered_model_name")

print("Python -- Updated Latest Best Model for Deployment")
