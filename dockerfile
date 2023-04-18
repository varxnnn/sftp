FROM atmoz/sftp:alpine

ENV USER=testuser

# Create a group and user (ALPINE IMAGES USE ADDGROUP AND ADDUSER instead of USERADD GROUPADD)
RUN adduser -D $USER && mkdir -p /etc/sudoers.d \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER