param location string 

param environment string 

param projectprefix string

param zonename string

var managedIdentityName = 'identity-${projectprefix}-${environment}'

var registry_name = 'acr${projectprefix}${environment}'

var creatednszone = (environment == 'test') ? true : false

var acrPullRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')


resource registry_resource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registry_name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
  }
}

/*
The managed identity is created and assigned to the rbac container registry . The MI wil be 
attached to the container instance thereby helping it to pull the ACR image . 
*/
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

/*
The managed identity is assigned a roll of acrPullRole for pulling the image from the registry
*/
resource rollAssignentforContInstOnContainerRegistry 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, registry_resource.name, acrPullRole)
  scope: registry_resource
  properties: {
    description: 'Rbac roll assignment'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: acrPullRole
  }
}

resource testdnszone 'Microsoft.Network/dnsZones@2018-05-01' =  if (creatednszone) {
  name: zonename
  location: 'global'
}


