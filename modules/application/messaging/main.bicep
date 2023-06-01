/*
.Synopsis
    Main Bicep template for service bus and replication

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230313

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

param resourceGroupNameUKS string
param resourceGroupNameUKW string = ''
param sbReplication bool

param tags object

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource resourceGroupUKS 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: resourceGroupNameUKS
}

resource resourceGroupUKW 'Microsoft.Resources/resourceGroups@2022-09-01' existing = if (!empty(resourceGroupNameUKW)) {
  scope: subscription()
  name: resourceGroupNameUKW
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Service Bus //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var serviceBuses = {
  NPD: [
    {
      deploymentName: 'serviceBus001-${location}-${variables.global.environmentName}'
      serviceBusName: variables.global.serviceBusName001
    }
  ]
  PRE: [
    {
      deploymentName: 'serviceBus001-${location}-${variables.global.environmentName}'
      serviceBusName: variables.global.serviceBusName001
    }
  ]
  PRD: [
    {
      deploymentName: (location == 'uksouth') ? 'serviceBus001-${location}-${variables.global.environmentName}' : 'serviceBus002-${location}-${variables.global.environmentName}'
      serviceBusName: (location == 'uksouth') ? variables.prd.uksouth.serviceBusName001 : variables.prd.ukwest.serviceBusName001
    }
  ]
}

@description('Service Bus for service communications')
module serviceBus_resource 'modules/servicebus.bicep' = [for serviceBus in serviceBuses[variables.global.environmentName]: if (sbReplication) {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(serviceBus.deploymentName)
  params: {
    location: toLower(location)
    serviceBusName: toLower(serviceBus.serviceBusName)
    privateLinkOption: true
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: []
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Private Endpoints ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var privateEndpoints = {
  deploymentName: (location == 'uksouth') ? 'serviceBus001_pe001-${location}-${variables.global.environmentName}' : 'serviceBus001_pe002-${location}-${variables.global.environmentName}'
  privateEndpointName: (location == 'uksouth') ? '${variables.global.serviceBusName001}-pe-001' : '${variables.global.serviceBusName001}-pe-002'
  privateLinkServiceId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.ServiceBus/namespaces/${variables.global.serviceBusName001}' : '${resourceGroupUKW.id}/providers/Microsoft.ServiceBus/namespaces/${variables.global.serviceBusName001}'
  privateLinkServiceGroupIds: 'namespace'
  privateDnsZoneConfigs: [
    {
      name: 'privatelink-servicebus-windows-net'
      properties: {
        privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-servicebus-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-servicebus-windows-net', '-', '.')}'
      }
    }
  ]
  virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName13}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName13}'
}

@description('Private endpoints')
module privateEndpoint_resource '../../network/modules/privateendpoint.bicep' = {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(privateEndpoints.deploymentName)
  params: {
    location: location
    privateEndpointName: toLower(privateEndpoints.privateEndpointName)
    privateLinkServiceId: privateEndpoints.privateLinkServiceId
    privateLinkServiceGroupIds: privateEndpoints.privateLinkServiceGroupIds
    virtualNetworkSubnetId: privateEndpoints.virtualNetworkSubnetId
    privateDnsZoneConfigs: privateEndpoints.privateDnsZoneConfigs
    tags: tags
  }
  dependsOn: [
    serviceBus_resource
  ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Replication //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module serviceBus_drconfig 'modules/servicebus_replica.bicep' = if (location == 'ukwest' ? sbReplication : false) {
  scope: resourceGroupUKS
  name: toLower('serviceBusLink-${location}-${variables.global.environmentName}')
  params: {
    serviceBusLinkName: toLower(variables.global.serviceBusLink001)
    primaryNamespaceName: toLower(variables.prd.uksouth.serviceBusName001)
    secondaryNamespaceName: toLower(variables.prd.ukwest.serviceBusName001)
    secondaryNamespaceResourceGroupName: resourceGroupUKW.name
  }
  dependsOn: [
    serviceBus_resource
    privateEndpoint_resource
  ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Outputs /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
