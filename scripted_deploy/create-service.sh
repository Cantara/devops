#!/bin/bash

if [[ $# -eq 0 ]] ; then
  echo "Usage: create-service.sh <ServiceName>"
  exit 1
fi

username=$1
echo Create User $username
#useradd -m $username

suToFile=su_to_$username.sh
if [ -e $suToFile ]; then
  echo "File $suToFile already exists!"
else
  echo '#!/bin/bash' > $suToFile
  echo 'sudo su - '$username >> $suToFile
fi
