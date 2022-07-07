
### FMRIB Server Connection and Setup
##### VPN Connection using Cisco
```
vpn.ox.ac.uk (then type ur user ID and password)
```

##### SSH Tunnel
```
ssh winokl@jalapeno.fmrib.ox.ac.uk
ssh -C -L 5931:localhost:5931 winokl@jalapeno.fmrib.ox.ac.uk
```

##### Login Password
```
<see key file>
```

##### Navigating to My Directory
```
cd /zxiong/OxfordCVM/
```

##### Python Activating Virtual Environment
```
source /home/fs0/winokl/zxiong/env/bin/activate
```

##### Python VS Code Interpreter Python Virtual Environment Path
```
/home/fs0/winokl/zxiong/env/bin/python
```

##### Copying Data Files to/from Server to/from Local Windows (Example)
```
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
pscp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/NeuroPM/io .
```

##### Dependencies for NeuroPM (MATLAB Toolboxes):
```
- statistics and machine learning toolbox
- financial toolbox
- optimization toolbox
- bioinformatics toolbox
```

##### FMRIB Cluster Commands
```
- link to resource
https://sharepoint.nexus.ox.ac.uk/sites/NDCN/FMRIB/IT/User%20Guides/GridEngine.aspx

- to run preprocessing + neuroPM in one script (Unlimited RAM and Hours, needed for full UKB, but slow)
fsl_sub -q bigmem.q ./run_model.sh
fsl_sub -q bigmem.q ./run_x_validate.sh

- to run python post processing (using virtual env)
./run_python.sh

- manage active jobs
qstat (check status)
qdel job_id (delete jobs)
```
