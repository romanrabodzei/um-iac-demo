/*
.Synopsis
    Bicep template for App Service plan. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Web/serverfarms?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230508
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// appServicePlanParameters
param location string
param appPlanName string

/// appServicePlanSku
param appPlanSkuName string = 'S1'
param appPlanSkuTier string = 'Standard'
param appPlanNumberOfWorkers int = 1
param autoScaling bool

/// appServicePlanConfiguration
param applicationServiceEnvironmentName string = ''
var id = {
  id: applicationServiceEnvironment.id
}

/// appServicePlanMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource applicationServiceEnvironment 'Microsoft.Web/hostingEnvironments@2022-03-01' existing = {
  name: toLower(applicationServiceEnvironmentName)
}

resource serverFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: toLower(appPlanName)
  location: location
  tags: tags
  properties: {
    hostingEnvironmentProfile: ((applicationServiceEnvironment.id != '') ? id : null)
  }
  sku: {
    name: appPlanSkuName
    tier: appPlanSkuTier
    capacity: appPlanNumberOfWorkers
  }
}

resource serverFarm_autoScaling 'Microsoft.Insights/autoscalesettings@2021-05-01-preview' = if (autoScaling == true) {
  name: toLower('${appPlanName}-Autoscale')
  location: location
  tags: tags
  properties: {
    name: toLower('${appPlanName}-Autoscale')
    enabled: true
    targetResourceUri: serverFarm.id
    profiles: [
      {
        name: 'Auto created scale condition'
        capacity: {
          minimum: '1'
          maximum: '8'
          default: '1'
        }
        rules: [
          {
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: serverFarm.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 70
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: serverFarm.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: 40
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              dimensions: []
              dividePerInstance: false
            }
          }
        ]
      }
    ]
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: serverFarm
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output serverFarmId string = serverFarm.id
