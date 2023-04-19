#### THIS SCRIPT GETS EXECUTED DURING THE WORKFLOW
#### THIS IS THE ACTUAL CODE THAT TRANSFERS THE FILES

HOST=$sftp_host
USER=$sftp_user
PASSWD=$sftp_password
## THESE ARE DECLARED IN ./github/workflows/TESTING-SFTP.YML file.
## We stored these creds as GitHub Actions, set them as env variables 
## during the execution of our workflow. (:

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
