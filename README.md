# OxfordCVM

# ssh tunnels
ssh winokl@jalapeno.fmrib.ox.ac.uk

ssh -C -L 5931:localhost:5931 winokl@jalapeno.fmrib.ox.ac.uk

# password
Hersenen.kijken9!

# copying files (example)
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong

# going to my path
cd /zxiong/OxfordCVM/

# activating virtual environment
source /home/fs0/winokl/zxiong/env/bin/activate

# interpreter python virtual env path
/home/fs0/winokl/zxiong/env/bin/python
