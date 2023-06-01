/*
.Synopsis
    Bicep template for Azure Data Factory. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/factories?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// datafactoryParameters
param location string
param dataFactoryName string

/// datafactoryIdentity
param userAssignedIdentityName string

/// datafactoryMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource userAssignedIdentity 'Microsoft.ManagedIdentity/identities@2022-01-31-preview' existing = {
  name: userAssignedIdentityName
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: toLower(dataFactoryName)
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    globalParameters: {}
    publicNetworkAccess: 'Disabled'
  }
}

resource dataFactoryManagedVirtualNetworks 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: toLower('${dataFactoryName}/default')
  properties: {}
  dependsOn: [
    dataFactory
  ]
}

resource dataFactoryIntegrationRuntimes 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: toLower('${dataFactoryName}/AutoResolveIntegrationRuntime')
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 0
        }
      }
    }
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: 'default'
    }
  }
  dependsOn: [
    dataFactoryManagedVirtualNetworks
  ]
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: dataFactory
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
      }
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
      {
        category: 'SandboxPipelineRuns'
        enabled: true
      }
      {
        category: 'SandboxActivityRuns'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessages'
        enabled: true
      }
      {
        category: 'SSISPackageExecutableStatistics'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessageContext'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionComponentPhases'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionDataStatistics'
        enabled: true
      }
      {
        category: 'SSISIntegrationRuntimeLogs'
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


output dataFactoryId string = dataFactory.id
