# Setting Up SFTP

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
      - ${SFTP_USERNAME}:${SFTP_PASSWORD}:1001::${TARGET}
    volumes:
      - ./keys/ssh_host_rsa_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_rsa_key.pub:ro
      - ./keys/ssh_host_ed25519_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_ed25519_key.pub:ro
```
- Then, we run the following script:
```bash
HOST=<IP:/port>
USER=<SFTP_USERNAME>
PASSWD=<SFTP_PASSWORD>

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
set ftp:use-allo false
set ftp:passive-mode true
set ftp:prefer-epsv false
open sftp://$USER:$PASSWD@$HOST
user $USER $PASSWD
mput -d build/* 
bye
END_SCRIPT
```
This will transfer the contents of the local `build` folder to the **TARGET** specified in the `.env` file. 