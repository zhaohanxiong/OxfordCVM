## FMRIB Server Commands
##### SSH tunnels
ssh winokl@jalapeno.fmrib.ox.ac.uk

ssh -C -L 5931:localhost:5931 winokl@jalapeno.fmrib.ox.ac.uk

##### Login Password
Hersenen.kijken9!

##### Copying Data Files into Server (example)
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong

##### Navigating to My Directory
cd /zxiong/OxfordCVM/

##### Activating Virtual Environment
source /home/fs0/winokl/zxiong/env/bin/activate

##### VS Code Interpreter Python Virtual Environment Path
/home/fs0/winokl/zxiong/env/bin/python
