param projectprefix string
param environment string
param location string
param tag string
param sannamecertificate string

@description('The value of the CPU assigned to the containerapps')
param cpu int

@description('The value of the memory assigned to the containerapps')
param memory string

@description('Target Port in containers for traffic from ingress')
param targetport int

@description('Exposed Port in containers for TCP traffic from ingress')
param exposedport int

@description('Name of the container')
param name int

@description('Minimum number of container replicas.')
param minReplica int

@description('Maximum number of container replicas')
param maxReplica int

var managedenvironmentname = 'manangedenvironment${projectprefix}${environment}'
var containerappname = 'ca${environment}${projectprefix}'

var managedIdentityName ='identity-${projectprefix}-${environment}'
var resourcegroupstateful ='rg-${projectprefix}-${environment}-stateful'
var registry_name = 'acr${projectprefix}${environment}'
var reponame = 'example_repo'


resource managedenvironment 'Microsoft.App/managedEnvironments@2023-05-02-preview' = {
  name: managedenvironmentname
  location: location
  properties: {
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
  scope: resourceGroup(resourcegroupstateful)
}


resource containerapps 'Microsoft.App/containerapps@2023-05-02-preview' = {
  name: containerappname
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedenvironment.id
    environmentId: managedenvironment.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          identity: managedIdentity.id
          server: '${registry_name}.azurecr.io'
        }
      ]
      ingress: {
        external: true
        targetPort: targetport
        exposedPort: exposedport
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        customDomains: [
          {
            name: sannamecertificate
            certificateId: managedenvironments_managedcertificates.id
            bindingType: 'SniEnabled'
          }
        ]
        allowInsecure: false
        clientCertificateMode: 'Ignore'
        stickySessions: {
          affinity: 'sticky'
        }
      }
    }
    template: {
      containers: [
        {
          image: '${registry_name}.azurecr.io/${reponame}:${tag}'
          name: name
          resources: {
            cpu: cpu
            memory: memory
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
      }
    }
  }
}

resource managedenvironments_managedcertificates 'Microsoft.App/managedEnvironments/managedCertificates@2023-05-01' = {
  name: 'cert'
  location: location
  parent: managedenvironment
  properties: {
    domainControlValidation: 'CNAME'
    subjectName: sannamecertificate
  }
}
