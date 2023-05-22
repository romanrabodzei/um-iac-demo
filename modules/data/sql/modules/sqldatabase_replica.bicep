/*
.Synopsis
    Bicep template for SQL Database. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/servers/databases?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230302
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// sqlDatabaseParameters
param location string
param sqlDatabaseName string

/// sqlDatabaseConfiguration
param sqlServerName string
param licenseType string = 'LicenseIncluded'

/// sqlDatabaseMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// sqlDatabaseReplica
param sourceSqlDatabaseResourceGroupName string = ''
param sourcesqlServerName string = ''
param sourceSqlDatabaseName string = ''

/// tags
param tags object

/// resources
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: toLower(sqlServerName)
}

resource sourceSqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  scope: resourceGroup(sourceSqlDatabaseResourceGroupName)
  name: toLower(sourcesqlServerName)
  resource sourceSqlDatabase 'databases' existing = {
    name: toLower(sourceSqlDatabaseName)
  }
}

resource sqlDatabase_replica 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: toLower(sqlDatabaseName)
  location: location
  tags: tags
  properties: {
    createMode: 'Secondary'
    secondaryType: 'Geo'
    sourceDatabaseId: sourceSqlServer::sourceSqlDatabase.id
    zoneRedundant: false
    licenseType: licenseType
    readScale: 'Disabled'
    highAvailabilityReplicaCount: 0
    requestedBackupStorageRedundancy: 'Local'
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: sqlDatabase_replica
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
      }
      {
        category: 'AutomaticTuning'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
      }
      {
        category: 'Errors'
        enabled: true
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
      }
      {
        category: 'Timeouts'
        enabled: true
      }
      {
        category: 'Blocks'
        enabled: true
      }
      {
        category: 'Deadlocks'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
  }
}
