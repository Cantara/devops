#!/bin/sh
 servicename=shareprocApi
 javabin=/usr/bin/java


cp upstart-template-amazon.conf upstart-amazon.conf
sed -i 's/{service-name}/'$servicename'/g' upstart-amazon.conf
#sed -i 's/{javabin}/'$javabin'/g' upstart-amazon.conf
sudo cp upstart-amazon.conf /etc/init/$servicename.conf
