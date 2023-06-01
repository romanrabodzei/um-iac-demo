/*
.Synopsis
    Bicep template for Application Service Environment. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Web/hostingEnvironments?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// applicationServiceEnvironmentParameters
param location string
param applicationServiceEnvironmentName string

/// applicationServiceEnvironmentNetwork
param virtualNetworkName string
param virtualNetworkSubnetName05 string

/// applicationServiceEnvironmentMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

// tags
param tags object

/// resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: toLower(virtualNetworkName)
  resource aseSubnet 'subnets' existing = {
    name: toLower(virtualNetworkSubnetName05)
  }
}

resource applicationServiceEnvironment 'Microsoft.Web/hostingEnvironments@2021-03-01' = {
  name: toLower(applicationServiceEnvironmentName)
  location: location
  tags: tags
  kind: 'ASEV2'
  properties: {
    internalLoadBalancingMode: 'Web, Publishing'
    clusterSettings: [
      {
        name: 'InternalEncryption'
        value: 'true'
      }
    ]
    virtualNetwork: {
      id: virtualNetwork::aseSubnet.id
    }
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: applicationServiceEnvironment
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'AppServiceEnvironmentPlatformLogs'
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

output applicationServiceEnvironmentId string = applicationServiceEnvironment.id
