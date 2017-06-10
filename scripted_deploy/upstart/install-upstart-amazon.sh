#!/bin/bash
if [[ $# -eq 0 ]] ; then
  echo "Usage: install-upstart-amazon.sh <ServiceName> "
  exit 1
fi

servicename=$1
javabin=/usr/bin/java

curl -o upstart-template-amazon.conf https://raw.githubusercontent.com/Cantara/devops/master/scripted_deploy/upstart/upstart-template-amazon.conf
cp upstart-template-amazon.conf upstart-amazon.conf
sed -i 's/{servicename}/'$servicename'/g' upstart-amazon.conf
#sed -i 's/{javabin}/'$javabin'/g' upstart-amazon.conf
sudo cp upstart-amazon.conf /etc/init/$servicename.conf

echo Script is saved to /etc/init/$servicename.conf
echo To start this service type: 
echo 
echo      "sudo initctl start $servicename"
echo
