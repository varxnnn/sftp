HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword

cd /home/testuser/build

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
open sftp://$HOST
user $USER $PASSWD

mput -d build/*
bye
END_SCRIPT