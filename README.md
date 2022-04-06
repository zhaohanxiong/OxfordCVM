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