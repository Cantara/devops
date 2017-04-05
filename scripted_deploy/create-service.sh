#!/bin/bash

if [[ $# -eq 0 ]] ; then
  echo "Usage: create-service.sh <ServiceName>"
  exit 1
fi
servicename=$1
username=$1
echo Create User $username
if id "$username" >/dev/null 2>&1; then
  echo "User exists, not updating."
else
  sudo useradd -m $username
fi


echo Create su_to_file
suToFile=su_to_$username.sh
if [ -e $suToFile ]; then
  echo "File $suToFile already exists. Not beeing updated."
else
  echo '#!/bin/bash' > $suToFile
  echo 'sudo su - '$username >> $suToFile
fi

echo create start-service.sh
startServiceFile=/home/$username/start-service.sh
if [ -e $startServiceFile ]; then
  echo "File $startServiceFile already exists!"
else
  echo '#!/bin/bash' | sudo tee --append $startServiceFile
  echo 'nohup /usr/bin/java  -jar /home/'$username'/'$servicename'.jar' | sudo tee --append $startServiceFile
fi

echo Set Ownership to files
sudo chown $username:$username $startServiceFile



