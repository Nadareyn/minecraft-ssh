#!/bin/bash
set -e

FOLDER=/data
OWNER_GROUP=sftp
NEW_KEY=0

# Regenerate keys
if [ ! -f "/etc/cache_keys/ssh_host_rsa_key" ]; then
  NEW_KEY=1
  echo "generate rsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/cache_keys/ssh_host_dsa_key" ]; then
  NEW_KEY=1
  echo "generate dsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "/etc/cache_keys/ssh_host_ecdsa_key" ]; then
  NEW_KEY=1
  echo "generate ecdsa key"
  ssh-keygen -f /etc/cache_keys/ssh_host_ecdsa_key -N '' -t ecdsa
fi

if [ $NEW_KEY -eq 1 ]; then
  echo "add volume /etc/cache_keys to avoid new generated keys at startup"
fi

echo "copy ssh keys"
cp /etc/cache_keys/* /etc/ssh/

if ! cut -d: -f1 /etc/passwd | grep -q $USERNAME; then
  echo "create user $USERNAME"
  useradd -M -d $FOLDER -G $OWNER_GROUP $USERNAME
  chown -R $USERNAME:$OWNER_GROUP $FOLDER
else
  echo "user $USERNAME already exit"
fi

# Change sftp password
echo "$USERNAME:$PASSWORD" | chpasswd

echo "start openssh"
exec "/usr/sbin/sshd -D"

echo "start papermc"
exec "java -Xms6G -Xmx6G -jar $FOLDER/$JAR_PATH --nogui"
# exec "$@"
