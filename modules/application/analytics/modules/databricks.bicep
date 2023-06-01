/*
.Synopsis
    Bicep template for Azure Databricks. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Databricks/workspaces?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// databricksParameters
param location string
param databricksWorkspaceName string

/// databricksSku
param databricksWorkspaceTier string = 'premium'

/// databricksConfiguration
param databricksWorkspaceRgName string

/// databricksNetwork
param VirtualNetworkId string
param virtualNetworkSubnetName array

/// databricksMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource databricksWorkspace 'Microsoft.Databricks/workspaces@2021-04-01-preview' = {
  name: toLower(databricksWorkspaceName)
  location: location
  tags: tags
  sku: {
    name: databricksWorkspaceTier
  }
  properties: {
    managedResourceGroupId: resourceId('Microsoft.Resources/resourceGroups', databricksWorkspaceRgName)
    parameters: {
      enableNoPublicIp: {
        value: true
      }
      customVirtualNetworkId: {
        value: VirtualNetworkId
      }
      customPublicSubnetName: {
        value: virtualNetworkSubnetName[0]
      }
      customPrivateSubnetName: {
        value: virtualNetworkSubnetName[1]
      }
    }
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: databricksWorkspace
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'dbfs'
        enabled: true
      }
      {
        category: 'clusters'
        enabled: true
      }
      {
        category: 'accounts'
        enabled: true
      }
      {
        category: 'jobs'
        enabled: true
      }
      {
        category: 'notebook'
        enabled: true
      }
      {
        category: 'ssh'
        enabled: true
      }
      {
        category: 'workspace'
        enabled: true
      }
      {
        category: 'secrets'
        enabled: true
      }
      {
        category: 'sqlPermissions'
        enabled: true
      }
      {
        category: 'instancePools'
        enabled: true
      }
      {
        category: 'sqlanalytics'
        enabled: true
      }
      {
        category: 'genie'
        enabled: true
      }
      {
        category: 'globalInitScripts'
        enabled: true
      }
      {
        category: 'iamRole'
        enabled: true
      }
      {
        category: 'mlflowExperiment'
        enabled: true
      }
      {
        category: 'featureStore'
        enabled: true
      }
      {
        category: 'RemoteHistoryService'
        enabled: true
      }
      {
        category: 'mlflowAcledArtifact'
        enabled: true
      }
    ]
  }
}
