##### Tracking
```
- activate user interface
mlflow ui

- navigate to this location to acccess ui board (or click link in terminal)
http://localhost:5000/
```

##### Projects
```
- running locally
mlflow run .
```

##### Model Registry & Lifecycle Management
```
- running ml server for model lifecycle management, allows ml model registering
mlflow server --backend-store-uri sqlite:///mlruns.db --default-artifact-root ./mlruns

- transition from stored -> staging -> production -> archieve, click on models/versions then see the drop-down menu

- ml lifecycle workflow logic can be managed using conditional statements based on accuracy filters to declare the version and stage of model for deployment
```
