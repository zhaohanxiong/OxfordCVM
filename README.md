## AI Framework Bluepoint/Tech Stack for Cardiovascular Disease Modelling
![image](https://user-images.githubusercontent.com/29684281/188947616-5185127b-2c2e-40d7-a0df-9eab95b7c213.png)

## Projects Lead By Me
•	Bayesian dimensionality reduction, cluster analysis, and network analysis of population-wide medical databases (UK Biobank) for isolating predictive biomarkers and constructing disease progression trajectories

•	Scalable, interactive, and light weight visualization tools for sharing statistical outcomes from modelling

![Plotly_Demo](https://user-images.githubusercontent.com/29684281/177753046-d20de5fe-b60b-4b54-928b-d15dc5917caa.png)

![Rshiny_Demo](https://user-images.githubusercontent.com/29684281/177753060-3b01057d-e711-4a42-9106-7d2cec58ea29.png)

#### Data Version Control (DVC) - Used in Tandem with Git
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
git add .\src\fmrib\NeuroPM\<directory>.dvc

- commit all dvc/git changes and upload to remote storage (on S3 and GitHub), do git before dvc
git commit -m "commit message"
dvc push
git push

- retrieve data from remote storage (make sure AWS CLI is set up), do git before dvc
git pull origin
dvc pull
```
