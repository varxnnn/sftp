HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword

cd /home/runner/work/sftp/sftp
ls -l
chmod -R 665 build

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
set ftp:use-allo false
set ftp:passive-mode true
set ftp:prefer-epsv false
open sftp://$HOST
user $USER $PASSWD
mput -d build/*
bye
END_SCRIPT
