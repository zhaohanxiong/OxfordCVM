## AI Framework Bluepoint/Tech Stack for Hypertensive Cardiovascular Disease Modelling
![image](https://user-images.githubusercontent.com/29684281/188916007-10de5d23-d183-486a-8622-2eb9dcee1d8d.png)

## Projects Lead By Me
•	Bayesian dimensionality reduction, cluster analysis, and network analysis of population-wide medical databases (UK Biobank) for isolating predictive biomarkers and constructing disease progression trajectories

•	Scalable, interactive, and light weight visualization tools for sharing statistical outcomes from modelling

![Plotly_Demo](https://user-images.githubusercontent.com/29684281/177753046-d20de5fe-b60b-4b54-928b-d15dc5917caa.png)

![Rshiny_Demo](https://user-images.githubusercontent.com/29684281/177753060-3b01057d-e711-4a42-9106-7d2cec58ea29.png)

#### Data Version Control (DVC) - Used in Tandem with Git
```
- install dependencies
pip install dvc dvc-s3

- initialize dvc in the same directory with the .git to track code changes
dvc init

- add remote storage server to dvc
dvc remote add -d remote_storage s3://cti-ukb-data/io -f

- add data to dvc tracking, this makes sure that they wont be accidentally added to github
dvc add ./<directory>
git add .\src\fmrib\NeuroPM\io.dvc
git commit -m "commit message"

- upload to remote storage
dvc push
git push

- retrieve data from remote storage
dvc pull
```
