/*
.Synopsis
    Bicep template for Application Service Environment DNS zone and records. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Web/hostingEnvironments?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// applicationServiceEnvironmentParameters
param applicationServiceEnvironmentName string

/// applicationServiceEnvironmentNetwork
param virtualNetworkName string
var aseDnsZone = toLower('${applicationServiceEnvironmentName}.appserviceenvironment.net')

/// tags
param tags object

/// resources
resource virtualnetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: toLower(virtualNetworkName)
}

resource applicationServiceEnvironment 'Microsoft.Web/hostingEnvironments@2022-03-01' existing = {
  name: toLower(applicationServiceEnvironmentName)
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: aseDnsZone
  location: 'global'
  tags: tags
}

resource privateDnsZone_networkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualnetwork.id
    }
    registrationEnabled: false
  }
}

resource ase_star 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${applicationServiceEnvironment.id}/capacities/virtualip', '2021-03-01').internalIpAddress
      }
    ]
  }
}

resource ase_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${applicationServiceEnvironment.id}/capacities/virtualip', '2021-03-01').internalIpAddress
      }
    ]
  }
}

resource ase_at 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${applicationServiceEnvironment.id}/capacities/virtualip', '2021-03-01').internalIpAddress
      }
    ]
  }
}
