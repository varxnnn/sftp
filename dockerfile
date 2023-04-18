FROM atmoz/sftp:alpine

ENV USER=testuser

RUN adduser -D $USER && mkdir -p /etc/sudoers.d \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

# Create a group and user (ALPINE IMAGES USE ADDGROUP AND ADDUSER instead of USERADD GROUPADD)
# RUN addgroup -S testuser && adduser -S testuser -G testuser

# Tell docker that all future commands should run as the testuser user
# USER testuser

# RUN mkdir -p /home/testuser
