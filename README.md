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
SFTP_VERSION=latest
SFTP_USERNAME=testuser
SFTP_PASSWORD=testpassword
SFTP_PORT=22
```
- Create docker-compose.yml
```yaml
version: '3.7'

services:
  sftp:
    image: ${SFTP_IMAGE}:${SFTP_VERSION}
    container_name: sftp
    restart: always
    expose:
      - "${SFTP_PORT}"
    ports:
      - "${<whatever host port u want>}:${SFTP_PORT}"
    command:
      - ${SFTP_USERNAME}:${SFTP_PASSWORD}:1001::${DATA_STORE}   # syntax: user:password[:e][:uid[:gid[:dir1[,dir2]...]]]
    volumes:
      - ./keys/ssh_host_rsa_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_rsa_key.pub:ro
      - ./keys/ssh_host_ed25519_key.pub:/home/${SFTP_USERNAME}/.ssh/ssh_host_ed25519_key.pub:ro
```
- Then, we run the following script:
