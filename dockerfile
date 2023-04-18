FROM atmoz/sftp:alpine

# Create a group and user (ALPINE IMAGES USE ADDGROUP AND ADDUSER instead of USERADD GROUPADD)
RUN adduser -D testuser