
### FMRIB Server Connection and Setup
##### Connect
```
- VPN Connection using Cisco
vpn.ox.ac.uk (then type ur user ID and password)

- SSH Tunnel
ssh winokl@jalapeno.fmrib.ox.ac.uk
<password in keyfile>
```

##### Navigate Directories
```
- location of this codebase
cd /home/fs0/winokl/zxiong/OxfordCVM

- Activating Conda Environment (prefered)
source activate env_conda

- Activating Virtual Environment
source /home/fs0/winokl/zxiong/env/bin/activate

- Copying Data Files to/from Server to/from Local Windows (Example)
scp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
scp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/NeuroPM/io .
```

##### FMRIB Cluster Run Commands
```
- link to documentation: https://sharepoint.nexus.ox.ac.uk/sites/NDCN/FMRIB/IT/User%20Guides/GridEngine.aspx

- to run preprocessing + neuroPM in one script (UKB cTI)
fsl_sub -q bigmem.q bash ./run_UKB_cTI.sh

- check job status
qstat

- delete job
qdel job_id
```
