# Create a new Service     
* Create user
* Create su_to scripts
* Create update service script
* Create start service script

### Download and create scripts
```
curl https://raw.githubusercontent.com/Cantara/devops/master/scripted_deploy/create-service.sh
./create-service <ServiceName> <org.group.id>
#Eg ./create-service microservice-baseline no.cantara.service
```

### Download jar, and start service
```
./su_to...
./update-service.sh
./start-service.sh
```
