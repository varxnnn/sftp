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

## The Process:
- SSH into server
- Create ./keys/ and then the actual keys using the following commands (no passphrase):
```bash
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```
- Create a `.env` file with the following values:
```
SFTP_IMAGE=atmoz/sftp
SFTP_VERSION=alpine
SFTP_USERNAME=testuser
SFTP_PASSWORD=testpassword
SFTP_PORT=9090
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
- Then, we run the following script:
```bash
HOST=$sftp_host           # See script.sh for more deets (:
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
This will MIRROR the contents of the local `build` folder to the **TARGET** specified in the `.env` file. 
**MAKE SURE THAT THE TARGET FOLDER INSIDE THE CONTAINER AND THE HOST DIRECTORY YOU'LL MOUNT TO THAT TARGET DIRECTORY HAVE ADEQUATE ACCESS PERMISSIONS.**
