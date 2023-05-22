/*
.Synopsis
    Main Bicep template for data services: storage accounts and containers

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230327

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

param tags object

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource resourceGroupUKS 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: resourceGroupNameUKS
}

resource resourceGroupUKW 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(resourceGroupNameUKW)) {
  scope: subscription()
  name: resourceGroupNameUKW
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Storage accounts /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var storageAccounts = {
  NPD: [
    // standard storage accounts
    {
      deploymentName: 'storageAccount1001bl001-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountNameNPD001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // storage account for azure functions
    {
      deploymentName: 'storageAccountAFName001-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName002-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName003-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName003
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountDatalakeMo001bl001-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountDatalakeNameNPD101
      storageAccountAccessTier: 'Cool'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountDatalakeMo001bl002-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountDatalakeNameNPD102
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
  ]
  PRE: [
    // standard storage accounts
    {
      deploymentName: 'storageAccountPT1001bl001-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountNamePRE001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // storage account for azure functions
    {
      deploymentName: 'storageAccountAFName001-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName002-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName003-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName003
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountDatalakePT1001dl001-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountDatalakeNamePRE101
      storageAccountAccessTier: 'Cool'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountDatalakePT1001dl002-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountDatalakeNamePRE102
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
  ]
  PRD: [
    // standard storage accounts
    {
      deploymentName: 'storageAccount1001bl001-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountNamePRD001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // storage account for azure functions
    {
      deploymentName: 'storageAccountAFName001-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName001
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName002-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountAFName003-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName003
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: false
      privateLinkOption: true
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountDatalake1001dl001-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountDatalakeNamePRD001
      storageAccountAccessTier: 'Cool'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
    {
      deploymentName: 'storageAccountDatalake1001dl002-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountDatalakeNamePRD002
      storageAccountAccessTier: 'Hot'
      allowSharedKeyAccess: true
      isHnsEnabled: true
      privateLinkOption: true
    }
  ]
}

@description('Storage account')
module storageAccount_resource 'modules/storageaccount.bicep' = [for storageAccount in storageAccounts[variables.global.environmentName]: if (location == 'uksouth') {
  scope: resourceGroupUKS
  name: toLower(storageAccount.deploymentName)
  params: {
    location: location
    storageAccountName: toLower(storageAccount.storageAccountName)
    storageAccountAccessTier: storageAccount.storageAccountAccessTier
    allowSharedKeyAccess: storageAccount.allowSharedKeyAccess
    isHnsEnabled: storageAccount.isHnsEnabled
    privateLinkOption: storageAccount.privateLinkOption
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: []
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Storage accounts containers //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var storageAccountContainers = {
  NPD: [
    // standard storage accounts
    {
      deploymentName: 'storageAccount1001bl001BlobContainers-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountNameNPD001
      containerName: [
        'marketinteractionmessages'
        'evpm'
        'status'
        'marketinteractionvalidationandtransformationfiles'
      ]
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccount1001dl001Containers-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountDatalakeNameNPD101
      containerName: [
        'timesamples-backup'
      ]
    }
    {
      deploymentName: 'storageAccount1001dl002Containers-${variables.global.environmentName}'
      storageAccountName: variables.npd.storageAccountDatalakeNameNPD102
      containerName: [
        'timesamples-curated'
        'timesamples-execution'
        'timesamples-bp01-ingress'
        'timesamples-bp01-archive'
        'timesamples-bp01-err'
      ]
    }
    // Monitoring
    {
      deploymentName: 'storageAccountAF002Containers-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      containerName: [
        'monitoring-jsons'
      ]
    }
  ]
  PRE: [
    // standard storage accounts
    {
      deploymentName: 'storageAccountPT1001bl001Containers-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountNamePRE001
      containerName: [
        'marketinteractionmessages'
        'evpm'
        'status'
        'marketinteractionvalidationandtransformationfiles'
      ]
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountPT1001dl001Containers-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountDatalakeNamePRE101
      containerName: [
        'timesamples-backup'
      ]
    }
    {
      deploymentName: 'storageAccountPT1001dl002Containers-${variables.global.environmentName}'
      storageAccountName: variables.pre.storageAccountDatalakeNamePRE102
      containerName: [
        'timesamples-curated'
        'timesamples-execution'
        'timesamples-bp01-ingress'
        'timesamples-bp01-archive'
        'timesamples-bp01-err'
      ]
    }
    // Monitoring
    {
      deploymentName: 'storageAccountAF002Containers-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      containerName: [
        'monitoring-jsons'
      ]
    }
  ]
  PRD: [
    // standard storage accounts
    {
      deploymentName: 'storageAccount1001bl001BlobContainers-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountNamePRD001
      containerName: [
        'marketinteractionmessages'
        'evpm'
        'status'
        'marketinteractionvalidationandtransformationfiles'
      ]
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountDatalake1001dl001Containers-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountDatalakeNamePRD001
      containerName: [
        'timesamples-backup'
      ]
    }
    {
      deploymentName: 'storageAccountDatalake1001dl002Containers-${variables.global.environmentName}'
      storageAccountName: variables.prd.uksouth.storageAccountDatalakeNamePRD002
      containerName: [
        'timesamples-curated'
        'timesamples-execution'
        'timesamples-bp01-ingress'
        'timesamples-bp01-archive'
        'timesamples-bp01-err'
      ]
    }
    // Monitoring
    {
      deploymentName: 'storageAccountAF002Containers-${variables.global.environmentName}'
      storageAccountName: variables.global.storageAccountAFName002
      containerName: [
        'monitoring-jsons'
      ]
    }
  ]
}

@description('Storage account containers')
module storageAccountContainer_resource 'modules/storageaccountcontainer.bicep' = [for storageAccountContainer in storageAccountContainers[variables.global.environmentName]: if (location == 'uksouth') {
  scope: resourceGroupUKS
  name: toLower(storageAccountContainer.deploymentName)
  params: {
    storageAccountName: toLower(storageAccountContainer.storageAccountName)
    containerName: storageAccountContainer.containerName
  }
  dependsOn: [
    storageAccount_resource
  ]
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Private Endpoints ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var privateEndpoints = {
  NPD: [
    // storage accounts for azure functions
    {
      deploymentName: 'storageAccountAF001bl001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl001_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName001}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl002_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName002}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl002_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName002}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl003_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName003}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl003_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName003}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // standard storage accounts
    {
      deploymentName: 'storageAccount1001bl001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountNameNPD001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountNameNPD001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccount1001bl001_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountNameNPD001}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountNameNPD001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountMo001dl001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountDatalakeNameNPD101}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountDatalakeNameNPD101}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountMo001dl001_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountDatalakeNameNPD101}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountDatalakeNameNPD101}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountMo001bl002_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountDatalakeNameNPD102}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountDatalakeNameNPD102}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountMo001bl002_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.storageAccountDatalakeNameNPD102}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.npd.storageAccountDatalakeNameNPD102}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
  ]
  PRE: [
    // storage accounts for azure functions
    {
      deploymentName: 'storageAccountAF001bl001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl001_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName001}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl002_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName002}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl002_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName002}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl003_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName003}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountAF001bl003_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.global.storageAccountAFName003}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // standard storage accounts
    {
      deploymentName: 'storageAccountPT1001bl_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountNamePRE001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountNamePRE001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountPT1001bl_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountNamePRE001}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountNamePRE001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // datalake storage accounts
    {
      deploymentName: 'storageAccountPT1001dl_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountDatalakeNamePRE101}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountDatalakeNamePRE101}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountPT1001dl_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountDatalakeNamePRE101}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountDatalakeNamePRE101}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountPT1002dl_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountDatalakeNamePRE102}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountDatalakeNamePRE102}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: 'storageAccountPT1002dl_pe03-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.storageAccountDatalakeNamePRE102}-pe-003'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.pre.storageAccountDatalakeNamePRE102}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
  ]
  PRD: [
    // storage accounts for azure functions
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl001_pe01-${variables.global.environmentName}' : 'storageAccountAF001bl001_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName001}-pe-001' : '${variables.global.storageAccountAFName001}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl001_pe03-${variables.global.environmentName}' : 'storageAccountAF001bl001_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName001}-pe-003' : '${variables.global.storageAccountAFName001}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl002_pe01-${variables.global.environmentName}' : 'storageAccountAF001bl002_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName002}-pe-001' : '${variables.global.storageAccountAFName002}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl002_pe03-${variables.global.environmentName}' : 'storageAccountAF001bl002_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName002}-pe-003' : '${variables.global.storageAccountAFName002}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName002}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl003_pe01-${variables.global.environmentName}' : 'storageAccountAF001bl003_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName003}-pe-001' : '${variables.global.storageAccountAFName003}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountAF001bl003_pe03-${variables.global.environmentName}' : 'storageAccountAF001bl003_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.global.storageAccountAFName003}-pe-003' : '${variables.global.storageAccountAFName003}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.global.storageAccountAFName003}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // standard storage accounts
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountNamePROD001_pe01-${variables.global.environmentName}' : 'storageAccountNamePROD001_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountNamePRD001}-pe-001' : '${variables.prd.uksouth.storageAccountNamePRD001}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountNamePRD001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountNamePROD001_pe03-${variables.global.environmentName}' : 'storageAccountNamePROD001_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountNamePRD001}-pe-003' : '${variables.prd.uksouth.storageAccountNamePRD001}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountNamePRD001}'
      privateLinkServiceGroupIds: 'queue'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-queue-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-queue-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    // datalake storage account
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountDatalakeNamePROD001_pe01-${variables.global.environmentName}' : 'storageAccountDatalakeNamePROD001_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountDatalakeNamePRD001}-pe-001' : '${variables.prd.uksouth.storageAccountDatalakeNamePRD001}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountDatalakeNamePRD001}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountDatalakeNamePROD001_pe03-${variables.global.environmentName}' : 'storageAccountDatalakeNamePROD001_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountDatalakeNamePRD001}-pe-003' : '${variables.prd.uksouth.storageAccountDatalakeNamePRD001}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountDatalakeNamePRD001}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountDatalakeNamePROD002_pe01-${variables.global.environmentName}' : 'storageAccountDatalakeNamePROD002_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountDatalakeNamePRD002}-pe-001' : '${variables.prd.uksouth.storageAccountDatalakeNamePRD002}-pe-002'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountDatalakeNamePRD002}'
      privateLinkServiceGroupIds: 'dfs'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-dfs-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-dfs-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
    {
      deploymentName: (location == 'uksouth') ? 'storageAccountDatalakeNamePROD002_pe03-${variables.global.environmentName}' : 'storageAccountDatalakeNamePROD002_pe04-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.storageAccountDatalakeNamePRD002}-pe-003' : '${variables.prd.uksouth.storageAccountDatalakeNamePRD002}-pe-004'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Storage/storageAccounts/${variables.prd.uksouth.storageAccountDatalakeNamePRD002}'
      privateLinkServiceGroupIds: 'blob'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-blob-core-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName09}'
    }
  ]
}

@description('Private endpoints')
module privateEndpoint_resource_uksouth '../../network/modules/privateendpoint.bicep' = [for privateEndpoint in privateEndpoints[variables.global.environmentName]: {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
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
    storageAccount_resource
  ]
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Outputs /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
