
### FMRIB Server Connection and Setup
##### VPN Connection using Cisco
```
vpn.ox.ac.uk (then type ur user ID and password)
```

##### SSH Tunnel
```
ssh winokl@jalapeno.fmrib.ox.ac.uk
ssh -C -L 5931:localhost:5931 winokl@jalapeno.fmrib.ox.ac.uk
<password in keyfile>
```

##### Navigating to My Directory
```
cd /home/fs0/winokl/zxiong/OxfordCVM
```

##### Python Activating Virtual Environment/Conda Environment
```
source /home/fs0/winokl/zxiong/env/bin/activate
source activate env_conda
```

##### Copying Data Files to/from Server to/from Local Windows (Example)
```
scp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
scp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/NeuroPM/io .
```

##### FMRIB Cluster Run Commands
```
- link to resource
https://sharepoint.nexus.ox.ac.uk/sites/NDCN/FMRIB/IT/User%20Guides/GridEngine.aspx

- to run preprocessing + neuroPM in one script (Unlimited RAM and Hours, needed for full UKB, but slow)
fsl_sub -q bigmem.q bash ./run_all.sh
fsl_sub -q bigmem.q bash ./run_x_validate.sh

- manage active jobs
qstat (check status)
qdel job_id (delete jobs)
```

##### Dependencies for NeuroPM (MATLAB Toolboxes):
```
- statistics and machine learning toolbox
- financial toolbox
- optimization toolbox
- bioinformatics toolbox
```
