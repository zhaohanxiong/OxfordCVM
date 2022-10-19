
## CCRF GPU Server
##### Connect
- VPN using Cisco to Connect to Oxford Network
```
IP Address: vpn.ox.ac.uk
Input Username: (i.e. card0633)
Input Password: single-sign-on password
```

- SSH Tunnel
```
ssh zhaohanx@163.1.212.155
<type in your password>
```

- VS-Code Installation Setup for Connection
```
```

- VS-Code Setup for Connection
```
```

##### Navigate Directories
- location of your home directory (example)
```
cd /home/zxiong/
cd /home/winokl/
```

##### Code Base
- Download Code Base
```
git clone 
fetch all branches
delete prod branch
```

- Setup Code Base by Adding Directories Ignored by Git
```
io
ml_lifecycle stuff
tf-serving stuff
```

- Get Latest Code Version
```
git pull origin
```

- Edit Your Own Code Version
```
make ur own branch
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
