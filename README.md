# Dockerized SFTP
***
## The Problem:
When using GitHub Actions for CI/CD, the CD part might get a little compromising when it comes to security. 
We resort to SamKirkland's FTP function pretty often, don't we? As great as that action is, it wasn't fitting my use case. FTPS is a joke, 
really complicated to configure, and not as secure. 

## The Solution: 
This right here, a dockerized SFTP client. Still a work in progress, but yes, we inculcate this in our GitHub Actions and we're good!
The client needs to be configured on the server you want to send your files to, but I'm looking into ways to automate that as well. 
Shoutout to atmoz/sftp for making the process much, much easier. (:

Through this template, we will be able to **establish an SFTP connection between our target server and the runner our GitHub Action is being executed on.**

## The Process:
- SSH into server, go to your preferred directory.
- Create `keys` folder, get inside it, and then create the actual keys using the following commands (no passphrase):
```bash
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```
- Go UP a folder, create a `.env` file with the following values:
```
SFTP_IMAGE=atmoz/sftp
SFTP_VERSION=alpine
SFTP_USERNAME=<username>
SFTP_PASSWORD=<password>
SFTP_PORT=<preferred port>
TARGET=build
```
- Create docker-compose.yml
```yaml
---
services:
  sftp:
    image: ${SFTP_IMAGE}:${SFTP_VERSION}
    container_name: sftp
    restart: always
    ports:
      - "${SFTP_PORT}:22"
    command:
      - ${SFTP_USERNAME}:${SFTP_PASSWORD}:::${TARGET}
    volumes:
      - /path/to/folder/on/host/where/you/want/the/files:/home/${SFTP_USERNAME}/${TARGET}:rw,Z
      - ./keys/ssh_host_rsa_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_rsa_key.pub:ro
      - ./keys/ssh_host_ed25519_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_ed25519_key.pub:ro
```
- Run the container by executing the following command:
```shell
docker-compose up --build -d
```
- Now, create a GitHub Repository!
- Create your workflow:
  - Create `.github/workflows` directory at the root of your repo.
  - Create a `.yml` file with the following contents:
```yaml
name: Dockerized SFTP

on: 
  push:
    branches:
      [ master ]

env:
  sftp_host: ${{ secrets.SFTP_HOST }}
  sftp_user: ${{ secrets.SFTP_USER }}
  sftp_password: ${{ secrets.SFTP_PASSWORD }}

jobs:
  transferring_files:
    name: Transferring files with SFTP
    runs-on: ubuntu-latest
    steps:
      # Getting Latest code
    - name: Get latest code
      uses: actions/checkout@v3
      
      # Installing LFTP on our GitHub Hosted Runner
    - name: Configuring LFTP
      run: |
        sudo apt-get update
        sudo apt update
        sudo apt install lftp

      # Running script.sh
    - name: Running Script 
      run: |
        chmod 765 build                 
        echo "Updated Perms of Build"
        echo "-----------------------------------------------------------------------------------------------------------------"
        echo "Executing script:"
        chmod +x script.sh 
        ./script.sh
      # We also boost the perms of the build folder, 
      # the sample folder that has the contents we need to transfer.
```
- You might notice that we've used GitHub Actions in our workflow, so yes, we create the following secrets:
  **SECRET NAME   -   SECRET VALUE**
  ```
  SFTP_HOST     -   <serverip:port>
  SFTP_USER     -   <sftp user(from .env)> 
  SFTP_PASSWORD -   <sftp password (from .env)>
  ```
- And here's the script we are running in our workflow:
```bash
HOST=$sftp_host           # See the actual file for more details (:
USER=$sftp_user
PASSWD=$sftp_password

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
set ftp:use-allo false
set ftp:passive-mode true
set ftp:prefer-epsv false
open sftp://$USER:$PASSWD@$HOST
user $USER $PASSWD
mirror -R \
       --delete \
       --only-newer \
       --no-perms \
       --no-umask \
       --parallel=5 \
       --exclude-glob .git/ \
       --exclude-glob .svn/ \
       --exclude-glob .DS_Store/ \
       --exclude-glob ._* \
       --exclude-glob Thumbs.db/ \
       --verbose \
       ./build/
bye
END_SCRIPT
```
***
Now, you should be able to MIRROR the contents of the local `build` folder to the **TARGET** specified in the `.env` file. 
**MAKE SURE THAT THE TARGET FOLDER INSIDE THE CONTAINER AND THE HOST DIRECTORY YOU'LL MOUNT TO THAT TARGET DIRECTORY HAVE ADEQUATE ACCESS PERMISSIONS.**
