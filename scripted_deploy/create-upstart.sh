#!/bin/sh
if [[ $#  -ne 2 ]] ; then
  echo "Usage: create-upstart.sh <ServiceName> <UserName>"
  exit 1
fi
user=$2
service_name=$1

updateServiceFile=upstart.template
if [ -e $updateServiceFile ]; then
  echo "File $updateServiceFile already exists!"
else
  curl -o upstart.template https://raw.githubusercontent.com/Cantara/devops/master/scripted_deploy/upstart.template
fi  
cp upstart.template $service_name.template
sudo sed -i 's#<user>#'$user'#g' $service_name.template
sudo sed -i 's#<service-name>#'$service_name'#g' $service_name.template
sudo cp $service_name.template /etc/init/$service_name.conf
echo .....
echo Start service cmd:
echo sudo initctl start $service_name

