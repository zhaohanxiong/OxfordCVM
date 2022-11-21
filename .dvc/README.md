##### Data Version Control (DVC) - Used in Tandem with Git
```
- install dependencies
pip install dvc dvc-s3

- initialize dvc in the same directory with the ./.git to track code changes
dvc init

- set up AWS CLI (type the command below and input IAM access key/secret access from .csv file)
aws configure

- add remote storage server to dvc (using S3 URI)
dvc remote add -d remote_storage s3://cti-ukb-data/dvc -f

- check status of both data and code
dvc status
git status

- add data to dvc tracking, this makes sure that they wont be accidentally added to git, do git before dvc
dvc add ./<directory>
git add .\src\modelling\NeuroPM\<directory>.dvc

- commit all dvc/git changes and upload to remote storage (on S3 and GitHub), do git before dvc
git commit -m "commit message"
dvc push
git push

- retrieve data from remote storage (make sure AWS CLI is set up), do git before dvc
git pull origin
dvc pull
```
