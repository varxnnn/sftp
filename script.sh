HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
set ftp:use-allo false
set ftp:passive-mode true
set ftp:prefer-epsv false
open sftp://$USER:$PASSWD@$HOST
user $USER $PASSWD
mirror -R \
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

# Transfer the zip file separately
set ftp:debug true
put ./build/artifacts.zip

bye
END_SCRIPT
