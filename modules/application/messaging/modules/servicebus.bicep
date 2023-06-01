/*
.Synopsis
    Bicep template for Service Bus. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.ServiceBus/namespaces?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// serviceBusParameters
param location string
param serviceBusName string

/// serviceBusSku
param serviceBusSkuName string = 'Premium'
param serviceBusSkuTier string = 'Premium'

/// serviceBusConfiguration
param serviceBusSkuCapacity int = 1
param privateLinkOption bool

/// serviceBusMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: toLower(serviceBusName)
  location: location
  tags: tags
  sku: {
    name: serviceBusSkuName
    tier: serviceBusSkuTier
    capacity: serviceBusSkuCapacity
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: ((location == 'uksouth') ? true : false)
  }
}

resource serviceBus_networkRules 'Microsoft.ServiceBus/namespaces/networkRuleSets@2021-06-01-preview' = {
  parent: serviceBus
  name: 'default'
  properties: {
    publicNetworkAccess: 'Disabled'
    trustedServiceAccessEnabled: true
    defaultAction: (privateLinkOption ? 'Deny' : 'Allow')
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: serviceBus
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'OperationalLogs'
        enabled: true
      }
      {
        category: 'VNetAndIPFilteringLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output serviceBusId string = serviceBus.id
