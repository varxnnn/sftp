HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword
TARGET=/home/testuser/build

cd /home/runner/work/sftp/sftp
# ls -l build
# chown -R $USER build
# chmod -R 777 build/*
# ls -l 
ls 

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
set ftp:use-allo false
set ftp:passive-mode true
set ftp:prefer-epsv false
open sftp://$USER:$PASSWD@$HOST
user $USER $PASSWD
mput -d $TARGET build/* 
bye
END_SCRIPT
