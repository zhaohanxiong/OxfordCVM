### Basic Linux Commands:
- ```cd /my/path``` (navigate directories)
- ```cd ..``` (navigate to outside the current directory)
- ```pwd``` (get current working directory)
- ```ls``` (list all files/folders in current directory)
- ```mkdir /name_of_new_folder``` (create directory)
- ```rm /filename``` (remove single files)
- ```rm -r /file/directory``` (remove entire directories)
- ```chmod -r 755``` or ```chmod -r 777``` (changing permissions of access)
- ```du -h file_name``` (check file size of file)

### Installing Git on Linux (Example of Linux Installation)
- most software can be installed directly from the web
- install from web via ```apt```
```
sudo apt-get update
sudo apt-get install git
git --version
```

- install from source (similar for all other software)
- download source: https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
```
tar xvzf git-2.9.5.tar.gz
cd git-2.9.5
./configure
make
sudo make install
```

### Installing Conda
- Conda Library Manager Installation
  - Download miniconda linux installer on your own desktop (computer) https://docs.conda.io/en/latest/miniconda.html#linux-installers
  - Select version with Python 3.9
  - Navigate back to your home directory e.g. ```cd /home/zhaohanx/```
  - Create a new directory ```mkdir miniconda```
  - Navigate inside the new directory ```cd miniconda```
  - Drag and drop your downloaded miniconda linux installer from your desktop into VS-Code and into the ```miniconda``` folder
  - Type ```bash Miniconda3-<name of the file you downloaded>.sh```

### CCRF Server User Setup
- https://github.com/zhaohanxiong/OxfordCVM/blob/prod/src/README.md
