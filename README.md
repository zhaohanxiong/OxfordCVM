## AI Framework Bluepoint/Tech Stack for Hypertensive Cardiovascular Disease Modelling
![image](https://user-images.githubusercontent.com/29684281/187767345-a49e0ca8-d66f-4a0e-8057-6b35b33736fb.png)

## Projects Lead By Me
•	Bayesian dimensionality reduction, cluster analysis, and network analysis of population-wide medical databases (UK Biobank) for isolating predictive biomarkers and constructing disease progression trajectories

•	Scalable, interactive, and light weight visualization tools for sharing statistical outcomes from modelling

![Plotly_Demo](https://user-images.githubusercontent.com/29684281/177753046-d20de5fe-b60b-4b54-928b-d15dc5917caa.png)

![Rshiny_Demo](https://user-images.githubusercontent.com/29684281/177753060-3b01057d-e711-4a42-9106-7d2cec58ea29.png)

#### Data Version Control (DVC) - Used in Tandem with Git
```
- initialize dvc in the same directory with the .git to track code changes
dvc init

- add remote storage server to dvc
dvc remote add -d remote_storage https://s3.<region-code>.amazonaws.com/<bucket-name>/<key-name>
dvc remote add -d remote_storage https://s3.us-east-1.amazonaws.com/cti-ukb-data

- add data to dvc tracking, this makes sure that they wont be accidentally added to github
dvc track ./<directory>
git commit -m "commit message"

- 

```