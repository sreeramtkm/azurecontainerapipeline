deploymentname=deployment-zeropm-rg
environment=prod
location=norwayeast
az stack sub create --deny-settings-mode 'none' --name $deploymentname --delete-resources --yes --template-file main.bicep --parameters ./parameters/$environment.parameters.json --location $location