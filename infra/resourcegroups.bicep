targetScope = 'subscription'

param location string

param principalId string

param environment string 

param projectprefix string

var resourcegroupnamestateful = 'rg-${projectprefix}-${environment}-stateful'

var resourcegroupnamestateless = 'rg-${projectprefix}-${environment}-stateless'



module rgstateless './modules/resource-group.bicep' = {
  name: 'rgstateless'
  params: {
    location: location
    resourceGroupName: resourcegroupnamestateless
    principalId: principalId
  }
}

module rgstateful './modules/resource-group.bicep' = {
  name: 'rgstateful'
  params: {
    location: location
    resourceGroupName: resourcegroupnamestateful
    principalId: principalId
  }
}


output resourcegroupstatefulname string = rgstateful.outputs.resourcegroupname
output resourcegroupstateflessname string = rgstateless.outputs.resourcegroupname

