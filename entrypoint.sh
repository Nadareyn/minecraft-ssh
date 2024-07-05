#!/bin/bash
set -e

FOLDER=/data
OWNER_GROUP=sftp

# Regenerate keys
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
  echo "generate rsa key"
  ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
  echo "generate dsa key"
  ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "/etc/ssh/ssh_host_ecdsa_key" ]; then
  echo "generate ecdsa key"
  ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
fi

if ! cut -d: -f1 /etc/passwd | grep -q $USERNAME; then
  echo "create user $USERNAME"
  #useradd -u $OWNER_ID -M -d $FOLDER -G $OWNER_GROUP -s /bin/false $USERNAME
  useradd -M -d $FOLDER -G $OWNER_GROUP $USERNAME
  chown -R $USERNAME:$OWNER_GROUP $FOLDER
else
  echo "an user has name $USERNAME"
  #usermod -u $OWNER_ID -G $OWNER_GROUP -a -d $FOLDER -s /bin/false $USERNAME
fi

# Change sftp password
echo "$USERNAME:$PASSWORD" | chpasswd

exec "$@"

echo "oh no"
tail -f /dev/null

 # Grab UID of owner of sftp home directory
  if [ -z $OWNER_ID ]; then
    OWNER_ID=$(stat -c '%u' $FOLDER)
  fi

  # Create appropriate SFTP user
  # If uid doesn't exist on the system
  if ! cut -d: -f3 /etc/passwd | grep -q $OWNER_ID; then
    echo "no user has uid $OWNER_ID"
    # If user doesn't exist on the system
    if ! cut -d: -f1 /etc/passwd | grep -q $USERNAME; then
      echo "no user has name $USERNAME"
      useradd -u $OWNER_ID -M -d $FOLDER -G $OWNER_GROUP -s /bin/false $USERNAME
    else
      echo "an user has name $USERNAME"
      usermod -u $OWNER_ID -G $OWNER_GROUP -a -d $FOLDER -s /bin/false $USERNAME
    fi
  else
    # If user doesn't exist on the system
    existing_user_with_uid=$(awk -F: "/:$OWNER_ID:/{print \$1}" /etc/passwd)
    echo "user with uid $OWNER_ID already exist ($existing_user_with_uid)"
    usermod -d $FOLDER -G $OWNER_GROUP -a -s /bin/false -l $USERNAME $existing_user_with_uid
  fi

# Change sftp password
echo "$USERNAME:$PASSWORD" | chpasswd

exec "$@"
