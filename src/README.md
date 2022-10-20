
## CCRF GPU Server
##### Connect
- VPN using Cisco to Connect to Oxford Network
```
IP Address: vpn.ox.ac.uk
Input Username: (i.e. card0633)
Input Password: single-sign-on password
```

- SSH Tunnel (Connection IP Address)
```
ssh zhaohanx@163.1.212.155
ssh winokl@163.1.212.155
```

- VS-Code Installation and Setup
  - Download: https://code.visualstudio.com/download
  - Go to extension tab (5th one down on the left hand side) and search/install
    - Remote - SSH (allows vs-code to be setup for SSH connections)
    - Python (viewing of python code)
    - Matlab (viewing of matlab code)
  - 3rd tab (on the left hand side) is Git embedded inside VS-Code
  - 4th tab (on the left hand side) is the debugger console (requires set up)
  - 6th tab (on the left hand side) should be the SSH plugin with a computer screen and "><" symbol

- VS-Code Setup for Connection
  - In the SSH plugin tab, click to open, the side panel should appear with "SSH TARGETS" as a heading
  - Press the "+" sign at the top of the side panel
  - VS-Code will then prompt you to enter an ssh command at a pop-up tab in the top
  - Enter the ssh command mentioned above with your own account name
  - Enter your password
  - You should now be connected to the CCRF server

##### Navigate Directories
- Initial steps
  - Click first tab on the left hand side to open the file explorer
  - Right click and click "open in integrated terminal"
  - Change password:
    - In terminal type ```passwd```
    - Enter your current and new password

- Check current directory you are in in the terminal
```
pwd
```

- Navigate to your home directory
```
cd /home/zxiong/
cd /home/winokl/
```

- Navigate out of the current directory (to a level above)
```
cd ..
```

- List everything in your current directory
```
ls -l
```

- Check file size of file
```
du -h file_name
```

- Create folders
```
mkdir folder_name
```

- Remove folder
```
rm -r folder_name
```

##### Code Base
- Download code base (you should see a new folder in your directory
```
git clone https://github.com/zhaohanxiong/OxfordCVM.git
```

- Set Up Code Base
```
git fetch --all
git pull --all
git pull dev
git branch dev
git branch -D prod
```

- To see full git tutorial, refer to ```/resources/tech_meetings/2022-10-06_git.md```

- Setup Code Base by Adding Directories Ignored by Git
```
cd OxfordCVM
mkdir /src/fmrib/NeuroPM/io
mkdir /src/aws/tf_serving/saved_models
mkdir /src/ml_lifecycle/mlflow/mlruns
mkdir /src/ml_lifecycle/mlflow/mlruns_staging
```

- Get Latest Code Version
```
git pull origin
```

- Edit Your Own Code Version
```
git branch test
git checkout test
```

- Go back to main working version of code
```
git add .
git commit -m "commited everything"
git checkout dev
```

##### Installing Dependencies
- Conda Library Manager Installation
```
```

- R Libraries
```
```

- Pip (Preferred Installer Program)
```
```

- Python Libraries
```
```

##### Data Transfer
- Your Own Computer to Server
```
```

- Server to Your Own Computer
```
```

## FMRIB Cluster
##### Connect
- VPN Connection using Cisco
```
vpn.ox.ac.uk (then type ur user ID and password)
```

- SSH Tunnel
```
ssh winokl@jalapeno.fmrib.ox.ac.uk
<password in keyfile>
```

##### Navigate Directories
- location of this codebase
```
cd /home/fs0/winokl/zxiong/OxfordCVM
```

- Activating Conda Environment (prefered)
```
source activate env_conda
```

- Activating Virtual Environment
```
source /home/fs0/winokl/zxiong/env/bin/activate
```

- Copying Data Files to/from Server to/from Local Windows (Example)
```
scp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
scp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/NeuroPM/io .
```

##### Cluster Run Commands
- link to documentation: https://sharepoint.nexus.ox.ac.uk/sites/NDCN/FMRIB/IT/User%20Guides/GridEngine.aspx
- extract the entire UKB dataset into a subset dataframe
```
fsl_sub -q bigmem.q Rscript ukb_whole_data_subset.R 
```

- to run preprocessing + neuroPM in one script (UKB cTI)
```
fsl_sub -q bigmem.q bash ./run_UKB_cTI.sh
```

- check job status
```
qstat
```

- delete job
```
qdel job_id
```
