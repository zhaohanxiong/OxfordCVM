### Virtual Environments
- Virtual environments are used to isolate dependencies (libraries, packages)
- A virtual environment contains an independent "system" which you can edit/change without impacting anything outside the environment
- It is bad practice to share dependencies between different projects
- Changes in one project's dependencies may adversely affect another
- Isolating, or "virtualizing", your development environment for each project allows the project to be independent
- This also allows ease of reproducibility as only the relevant dependencies for a certain project can be shared

### Demo - Python venv
```
python -m venv c:/path_to_you_env/env_name
c:/path_to_you_env/env_name/Scripts/Activate.ps1
deactivate
```
- ```venv``` is a virtual environment tool for python, there are also many others such as ```pipenv``` or ```virtual_env```
- The first line creates a virtual environment
- The second one activates it
- The third line deactivates it
- You can tell you are in a virtual environment if the start of your terminal has a ```(env_name)``` in front of it
- Otherwise if you cannot see the brackets, you should then activate it using the 2nd command

Installing libraries:
- Once you are inside the virtual environment, you can do various things like ```pip install``` to install packages such as ```numpy```
- These packages will only be accesible while you are inside the virtual environment
- Once you exit it, you will no longer have access to it

Freezing:
- You can freeze all your python dependencies with the command
```
pip freeze > requirements.txt
```
- This can then be shared with another user to install
```
pip install -r requirements.txt
```

VS-Code
- In VS-Code, you can select your python interpreter to be your virtual environment
- Open a ```.py``` file
- On the right hand bottom side, you can see your python version e.g. ```3.10.1```
- Click on this and enter the path to your virtual environment instead of the default python install on your computer
- In this example it would be ```c:/path_to_you_env/env_name/Scripts/python.exe``` which tells VS-Code that we want to use the python inside the virtual environment

### Demo - Conda
```
conda create --env_name
conda activate env_name
conda deactivate
```
- On linux, it may make more sense to use conda instead, especially if you have multiple languages
- After install conda, you can run the above commands which performs the same functions as described in the previous section above using ```venv```
- This virtual environment works in exact the same way, but you can also install dependencies for other languages such as R libraries
