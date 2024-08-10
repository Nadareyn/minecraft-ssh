#!/bin/bash
set -e

# Docker variables
USERNAME=${USERNAME:?Error USERNAME is not defined}
PASSWORD=${PASSWORD:?Error PASSWORD is not defined}
KEEP_ALIVE=${KEEP_ALIVE:=0}
JAR_PATH=${JAR_PATH:=}

# Script variables
FOLDER=/data
OWNER_GROUP=sftp
NEW_KEY=0

# Regenerate keys
if [ ! -f "/etc/cache_keys/ssh_host_rsa_key" ]; then
  NEW_KEY=1
  echo "Generate rsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/cache_keys/ssh_host_dsa_key" ]; then
  NEW_KEY=1
  echo "Generate dsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "/etc/cache_keys/ssh_host_ecdsa_key" ]; then
  NEW_KEY=1
  echo "Generate ecdsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_ecdsa_key -N '' -t ecdsa
fi

if [ $NEW_KEY -eq 1 ]; then
  echo "/!\ Add volume /etc/cache_keys to avoid new generated keys at startup"
fi

echo "copy ssh keys"
cp /etc/cache_keys/* /etc/ssh/

if ! cut -d: -f1 /etc/passwd | grep -q $USERNAME; then
  echo "Create user $USERNAME"
  useradd -M -d $FOLDER -G $OWNER_GROUP $USERNAME
  chown -R $USERNAME:$OWNER_GROUP $FOLDER
else
  echo "user $USERNAME already exit"
fi

# Change username password
echo "$USERNAME:$PASSWORD" | chpasswd

echo "Start openssh"
exec /usr/sbin/sshd
# exec /usr/sbin/sshd -D

if [ -f $FOLDER/$JAR_PATH ]; then
  echo "Start minecraft"  
  JAR_DIR="$(dirname $FOLDER/$JAR_PATH)"
  JAR_NAME="$(basename $FOLDER/$JAR_PATH)"
  cd $JAR_DIR
  su $USERNAME
  exec java -Xms6G -Xmx6G -jar $JAR_NAME --nogui
else
  echo "Minecraft jar file not found, please check environment variable \$JAR_PATH. It should match /$FOLDER/\$JAR_PATH"
fi

if [ $KEEP_ALIVE -eq 1 ]; then
  echo "Keep alive"
  exec tail -f /dev/null
else
  exec "$@"
fi
