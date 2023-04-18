FROM atmoz/sftp:alpine

# Create a group and user (ALPINE IMAGES USE ADDGROUP AND ADDUSER instead of USERADD GROUPADD)
RUN adduser -D testuser && mkdir -p /etc/sudoers.d \
        && echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser \
        && chmod 0440 /etc/sudoers.d/testuser