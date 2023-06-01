/*
.Synopsis
    Main Bicep template for databricks and data factory

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230302

           _
       .__(.)<  (MEOW)
        \___)
~~~~~~~~~~~~~~~~~~~~~~~~
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Deployment scope /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Parameters and variables ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

param variables object
param location string

param resourceGroupName string

param VirtualNetworkName string
param databricksSubnetNames array
param databricksUserAssignedIdentityName string

param tags object

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: resourceGroupName
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// Virtual Network ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup
  name: VirtualNetworkName
  resource databricksSubnetPublic 'subnets' existing = {
    name: databricksSubnetNames[0]
  }
  resource databricksSubnetPrivate 'subnets' existing = {
    name: databricksSubnetNames[1]
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////// Databricks /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Databricks workspace')
module databricksWorkspace_resource 'modules/databricks.bicep' = if (true) {
  scope: resourceGroup
  name: toLower('databricksWorkspace-${location}-${variables.global.environmentName}')
  params: {
    location: location
    databricksWorkspaceName: variables.global.databricksWorkspaceName
    databricksWorkspaceRgName: variables.global.databricksWorkspaceRgName
    VirtualNetworkId: virtualNetwork_resource.id
    virtualNetworkSubnetName: [
      virtualNetwork_resource::databricksSubnetPublic.id
      virtualNetwork_resource::databricksSubnetPrivate.id
    ]
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: []
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// DataFactory /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@description('DataFactory')
module dataFactory_resource 'modules/datafactory.bicep' = if (true) {
  scope: resourceGroup
  name: toLower('dataFactory-${location}-${variables.global.environmentName}')
  params: {
    location: location
    dataFactoryName: variables.global.dataFactoryName
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    userAssignedIdentityName: databricksUserAssignedIdentityName
    tags: tags
  }
  dependsOn: []
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Private Endpoints ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var privateEndpoints = [
  {
    deploy: true
    deploymentName: 'dataFactory_pe01-${location}-${variables.global.environmentName}'
    privateEndpointName: '${variables.global.dataFactoryName}-pe-001'
    privateLinkServiceId: '${resourceGroup.id}/providers/Microsoft.DataFactory/factories/${variables.global.dataFactoryName}'
    privateLinkServiceGroupIds: 'dataFactory'
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-datafactory-azure-net'
        properties: {
          privateDnsZoneId: '${resourceGroup.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-datafactory-azure-net', '-', '.')}'
        }
      }
    ]
    virtualNetworkSubnetId: '${resourceGroup.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName15}'
  }
  {
    deploy: true
    deploymentName: 'dataFactory_pe02-${location}-${variables.global.environmentName}'
    privateEndpointName: '${variables.global.dataFactoryName}-pe-002'
    privateLinkServiceId: '${resourceGroup.id}/providers/Microsoft.DataFactory/factories/${variables.global.dataFactoryName}'
    privateLinkServiceGroupIds: 'portal'
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-datafactory-azure-net'
        properties: {
          privateDnsZoneId: '${resourceGroup.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-datafactory-azure-net', '-', '.')}'
        }
      }
    ]
    virtualNetworkSubnetId: '${resourceGroup.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName15}'
  }
]

@description('Private endpoints')
module privateEndpoint_resource '../../../modules/network/modules/privateendpoint.bicep' = [for privateEndpoint in privateEndpoints: if (privateEndpoint.deploy) {
  scope: resourceGroup
  name: toLower(privateEndpoint.deploymentName)
  params: {
    location: location
    privateEndpointName: toLower(privateEndpoint.privateEndpointName)
    privateLinkServiceId: privateEndpoint.privateLinkServiceId
    privateLinkServiceGroupIds: privateEndpoint.privateLinkServiceGroupIds
    virtualNetworkSubnetId: privateEndpoint.virtualNetworkSubnetId
    privateDnsZoneConfigs: privateEndpoint.privateDnsZoneConfigs
    tags: tags
  }
  dependsOn: [
    dataFactory_resource
  ]
}]
