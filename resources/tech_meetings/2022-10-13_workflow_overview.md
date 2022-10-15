### Current workflow overview
- Located in ```src/run_UKB_cTI_subset.sh``` (subset of complete workflow)
- Basic commands:
	- ```Rscript my_r_code.R``` (run R code)
	- ```matlab my_matlab_code.m``` (run matlab code)
	- ```python my_python_code.py``` (run python code)
	- ```cd``` command for directory navigation
- How to navigate/find the code themselves
	- all files ran by current workflow is located in ```/src/fmrib```
- The workflow should work automatically
	- runs all scripts continuously one after the other
	- each file produces an output which is read in by the next file
	- the idea is that the workflow is set up to run automatically from start to finish
- Matlab code is currently compiled then ran, so extra commands are used
	- the file ```compile.sh``` shows how the compilation is performed
	- an executable is then generated representing the "compiled version"
	- a command is then used to run this compiled matlab code
	- this command can be seen in the ```.sh``` file

### Libraries and dependencies
- Complete list is located in the readme in ```/src/fmrib```
	- R version and libraries
	- Matlab version and libraries
	- Python version and libraries
- Virtual environment (conda)
	- virtual environments are isolated development environments
	- allows you to install packages/software in an isolated part of your computer
	- doesnt interfere with other environments in your computer
	- good practice to set up virtual environments for each different project
	- allows installation of packages when you dont have permission to on remote servers
	- conda is a virtual environment manager
	- ```source activate name_of_conda_env``` (to activate our virtual environment)
	- we use conda for installing python and R packages used in our workflow

### Best Coding Practices (using R as example)
- commenting every line or every few lines
- function headers should have clear descript of function inputs/outputs
- readability (limit commands per line of code), dont nest functions too much
- "column" code structure, not too many characters per line, allows viewing of multiple files easier
- arranging logic of code:
	- each file should have a level of detail
	- the main file should have an overview of main steps
	- subsequent files should then contain the detailed functions used by the main file
	- bad practice to include code of different level of detail in the same script
	- this makes code easier to read
	- also helps when picking up errors
	- keeps each script to a limited number of lines

### R vs Python vs Matlab
- Python and R are open source
- Matlab is closed source
- open source tools are always available for use
- since open source tools are in constantly development globally, standards are set for consistency
- matlab requires license to use it, and also licenses for each package (statistics, machine learning etc)
- licenses can expire
- limited number of licnses available for packages
- close source languages poses future risk where you wont be able to run or access your code due to licensing issues
- close source languages is also developed by a small number of people, so standards change over time
- old code on close source languages usually dont work on newer versions
- there is limited development for matlab, and new functions are slow (matlab was only able to read csv files since 2019)
- open source allows constant development, and adheres closely to the current state-of-the-art industry standard
- open source has a larger community of developers, so there are more resources online for when issues arise
- most companies use open source code due to these reasons
- we should only use closed source tools if we are given them
- any new code should be written in open source languages

### Workflow details for matlab component which is the NeuroPM cTI implementation
- preprocessing:
	- ```preprocess_data_preparation.R``` and ```preprocess_feature_selection.R``` using functions is ```preproces_utils.R```
	- this code is very customized so your code will most likely be different
- cTI - matlab code inputs:
	- ```run_NeuroPM.m``` (```/src/fmrib/NeuroPM```)
	- ```csv``` file for patients and features (N by M matrix, N = number of patients, M = number of features)
	- this is currently named ```ukb_num_norm_ft_select.csv```
	- ```csv``` file for labels (N by 1, N = number of patients, 1 = single column representing group of patient)
	- this is currently named ```labels_ft_select.csv```
	- current label file uses the column name ```bp_group``` for the grouping of patients
	- each patient is assigned a number ```0 or 1 or 2``` for their group
	- when using your own data, make sure to change this column name, as well as the label you are using to label ur patients ```0 = between, 1 = background, 2 = disease```
	- optional inputs for covariate adjustment and data harmonization, these are masked out using ```try``` and ```catch``` so code still runs if you dont have these files
- hypertension modelling - matlab code outputs:
	- output is ```pseudotimes.csv``` file of labels + additional column containing pseudotime score for each patient, with the column name ```global_pseudotimes```
	- ```var_weightings.csv``` file of weightings of each variable (M features) outputted
	- ```threshold_weighting.csv``` file for threshold value for the variable weightings
- postprocessing evaluation code:
	- ```postproces_evaluation.R``` (```/src/fmrib```)
	- processes the file containing the pseudotime score to perform evaluation
	- file also produces some visualization as well
