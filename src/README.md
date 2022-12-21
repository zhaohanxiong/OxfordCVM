
## CCRF GPU Server
### Connect
- VPN using Cisco to Connect to Oxford Network
```
IP Address: vpn.medsci.ox.ac.uk
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
  - You should also see a new SSH configuration in the side panel for your most recent connection
  - Next time you can simply right click on this and "Open in Current Window"

### Change Password
- Initial steps
  - Click first tab on the left hand side to open the file explorer
  - Right click and click "open in integrated terminal"
  - Change password:
    - In terminal type ```passwd```
    - Enter your current and new password

### Code Base
- Download code base (you should see a new folder in your directory
```
git clone https://github.com/zhaohanxiong/OxfordCVM.git
cd OxfordCVM
```

- Set Up Code Base (Organize Branches)
```
git fetch --all
git pull --all
git checkout dev
git branch --set-upstream-to=origin/dev dev
git branch -D prod
```

- To see full git tutorial, refer to ```/resources/tech_meetings/2022-10-06_git.md```

- Setup Code Base by Adding Directories Ignored by Git
```
mkdir src/modelling/NeuroPM/io
mkdir src/aws/tf_serving/saved_models
mkdir src/ml_lifecycle/mlflow/mlruns
mkdir src/ml_lifecycle/mlflow/mlruns_staging
```

- Ask for a copy of ```/src/modelling/NeuroPM/cTI-codes``` folder as it is not on git due to it being from an external group 

- Get Latest Code Version
```
git checkout dev
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

### Installing Dependencies
- Conda Library Manager Installation
  - Download miniconda linux installer on your own desktop (computer) https://docs.conda.io/en/latest/miniconda.html#linux-installers
  - Select version with Python 3.9
  - Navigate back to your home directory e.g. ```cd /home/zhaohanx/```
  - Create a new directory ```mkdir miniconda```
  - Navigate inside the new directory ```cd miniconda```
  - Drag and drop your downloaded miniconda linux installer from your desktop into VS-Code and into the ```miniconda``` folder
  - Type ```bash Miniconda3-<name of the file you downloaded>.sh``` to install
  - To set up environment path so you can use ```conda``` command: ```echo 'export PATH=/home/andyf/miniconda3/bin:$PATH' >> ~/.bashrc```
   
- Set up virtual environment (create, map, activate)
```
conda create --name env_name
export PATH=/home/username/miniconda3/bin:$PATH
activate env_name
```

- Install Python Libraries
```
conda install numpy
pip install scipy pandas networkx plotly seaborn matplotlib opencv-python sqlalchemy
```

- Install R Libraries
  - type ```yes``` following the terminal prompt
```
R
install.packages("data.table")
install.packages("R.matlab")
install.packages("ggplot2")
install.packages("gridExtra")
```

- Matlab
```
- You need to install matlab individually as licenses are given to individual accounts
- The linux setup file for Matlab 2020a is already downloaded
- Download/unzip this file in your own account folder and run the install file to install matlab
```

- Exit out of virtual environment
  - You should activate your virtual environment to install new libraries and run code
  - You should deactivate your virtual environment when you are finished with ```conda deactivate```

### Data Transfer
- Your Own Computer to Server
  - SHIFT+RIGHT CLICK "open powershell" (or any terminal)
  - Enter the following except replace with your user_id before the ```@```
  - Replace with the desired path after the ```:```
  - Enter your password for the CCRF server
```
scp -r file_to_transfer.txt zhaohanx@163.1.212.155:/home/zhaohanx
```

- Server to Your Own Computer
  - Open any terminal as above
  - Type the command with your own user_id and file/folder full path
  - Enter your password for the CCRF server
```
scp -r zhaohanx@163.1.212.155:/home/zhaohanx/file_to_transfer .
```

## FMRIB Cluster
### Connect
- VPN Connection using Cisco
```
vpn.medsci.ox.ac.uk (then type ur user ID and password)
```

- SSH Tunnel
```
ssh winokl@jalapeno.fmrib.ox.ac.uk
<password in keyfile>
```

### Navigate Directories
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
scp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/modelling/NeuroPM/io .
```

### Cluster Run Commands
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
