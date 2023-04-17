HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword

# cd <base directory for your put file>

lftp<<END_SCRIPT
set sftp:auto-confirm yes
set ssl:verify-certificate no
open sftp://$HOST
user $USER $PASSWD
cd /home/paisarewards/sftp/build
mput -d build/*
bye
END_SCRIPT