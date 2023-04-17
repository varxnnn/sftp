HOST=45.142.237.166:9090
USER=testuser
PASSWD=testpassword

# cd <base directory for your put file>

lftp<<END_SCRIPT
open sftp://$HOST
user $USER $PASSWD
cd /home/testuser/sftp
mput -d build/*
bye
END_SCRIPT