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
- running ml server for model lifecycle management, use this to view ui when managing models
mlflow server --backend-store-uri sqlite:///mlruns.db --default-artifact-root ./mlruns
```
