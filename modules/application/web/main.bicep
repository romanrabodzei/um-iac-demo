/*
.Synopsis
    Main Bicep template for app service environments and app service plans

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230427

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

var variables = json(loadTextContent('../../../parameters/infra.parameters.json'))
// param variables object
param location string

param resourceGroupNameUKS string
param resourceGroupNameUKW string = ''

param tags object

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(variables.global.virtualNetworkName)
  resource aseSubnet 'subnets' existing = {
    name: toLower(variables.global.virtualNetworkSubnetName05)
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Application Service Environment ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Application Service Environment')
module applicationServiceEnvironment_resource 'modules/ase.bicep' = if (true) {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower('applicationServiceEnvironment-${variables.global.environmentName}')
  params: {
    location: location
    applicationServiceEnvironmentName: toLower(variables.global.applicationServiceEnvironmentName)
    virtualNetworkName: toLower(variables.global.virtualNetworkName)
    virtualNetworkSubnetName05: toLower(variables.global.virtualNetworkSubnetName05)
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: []
}

@description('Application Service Environment private DNS zone')
module applicationServiceEnvironmentDnsZone 'modules/asednszone.bicep' = if (true) {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower('applicationServiceEnvironmentDnsZone-${variables.global.environmentName}')
  params: {
    applicationServiceEnvironmentName: toLower(variables.global.applicationServiceEnvironmentName)
    virtualNetworkName: toLower(variables.global.virtualNetworkName)
    tags: tags
  }
  dependsOn: [
    applicationServiceEnvironment_resource
  ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// App Service Plan /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var serverfarms = [
  {
    deploy: true
    deploymentName: 'serverfarm001-${variables.global.environmentName}'
    deploymentScope: (location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW
    appPlanName: variables.global.appServicePlanName001
    appPlanNumberOfWorkers: 1
    autoScaling: true
  }
  {
    deploy: true
    deploymentName: 'serverfarm002-${variables.global.environmentName}'
    deploymentScope: (location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW
    appPlanName: variables.global.appServicePlanName002
    appPlanNumberOfWorkers: 8
    autoScaling: false
  }
  /// monitoring
  {
    deploy: true
    deploymentName: 'serverfarm003-${variables.global.environmentName}'
    deploymentScope: variables.umsUss.resourceGroupName
    appPlanName: variables.global.appServicePlanName003
    appPlanNumberOfWorkers: 1
    autoScaling: true
  }
]

@description('App Service Plan')
module serverfarm_resource 'modules/asp.bicep' = [for serverfarm in serverfarms: if (serverfarm.deploy) {
  scope: resourceGroup(serverfarm.deploymentScope)
  name: toLower(serverfarm.deploymentName)
  params: {
    location: location
    appPlanName: toLower(serverfarm.appPlanName)
    appPlanSkuName: 'I1'
    appPlanSkuTier: 'Isolated'
    appPlanNumberOfWorkers: serverfarm.appPlanNumberOfWorkers
    autoScaling: serverfarm.autoScaling
    applicationServiceEnvironmentName: toLower(variables.global.applicationServiceEnvironmentName)
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: [
    applicationServiceEnvironment_resource
  ]
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Outputs /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

