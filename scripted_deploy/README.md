# Create a new Service     
* Create user
* Create su_to scripts
* Create update service script
* Create start service script

### Download and create scripts
```
curl -o create-service.sh https://raw.githubusercontent.com/Cantara/devops/master/scripted_deploy/create-service.sh
./create-service <ServiceName> <org.group.id>
#Eg ./create-service microservice-baseline no.cantara.service
```

### Download jar, and start service
```
./su_to_<ServiceName>
./update-service.sh
./start-service.sh
```
# Install as upstart/initctl

### Download script for EC2/Linux
```
curl -o install-upstart-amazon.sh https://raw.githubusercontent.com/Cantara/devops/master/scripted_deploy/upstart/install-upstart-amazon.sh
```

### Create runtime

```
./install-upstart-amazon.sh <ServiceName>
sudo initctl start <ServiceName>
```

### Suggestion

```
./su_to_<ServiceName>
mv start-service.sh manual-start-service.sh
ln -s yourjar.jar <ServiceName>.jar
```

Then replace the command in start-service.sh to
```
sudo initctl start <ServiceName>
```
This will prevent you from running two instances of your application or service.


