/*
.Synopsis
    Bicep template for Storage Account. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// storageAccountParameters
param location string
param storageAccountName string

/// storageAccountConfiguration
param storageAccountKind string = 'StorageV2'
param storageAccountType string = 'Standard_RAGZRS'
param storageAccountAccessTier string
param allowSharedKeyAccess bool
param isHnsEnabled bool
param privateLinkOption bool

/// storageAccountMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: toLower(storageAccountName)
  location: location
  tags: tags
  sku: {
    name: storageAccountType
  }
  kind: storageAccountKind
  properties: {
    accessTier: storageAccountAccessTier
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: allowSharedKeyAccess
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: (privateLinkOption ? 'Deny' : 'Allow')
    }
    isHnsEnabled: (isHnsEnabled ? true : false)
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: storageAccount
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output storageAccountId string = storageAccount.id
