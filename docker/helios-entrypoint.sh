#!/bin/bash
set -e
USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

#echo "updated"
#cut -d: -f1 /etc/group | sort
echo "Starting__ with UID: $USER_ID, GID: $GROUP_ID"
usermod -u $USER_ID phaethon
groupmod -g $GROUP_ID phaethon
export HOME=/home/phaethon
id phaethon
exec /usr/sbin/gosu phaethon /bin/bash