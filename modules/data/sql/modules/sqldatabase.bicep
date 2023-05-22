/*
.Synopsis
    Bicep template for SQL Database. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/servers/databases?tabs=bicep#template-format

.NOTES
    Author     : CoE Azure
    Company    : Itineris NV
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// sqlDatabaseParameters
param location string
param sqlDatabaseName string

/// sqlDatabaseSku
param sqlDatabaseTier string = 'BusinessCritical'
param sqlDatabaseSkuName string = 'BC_Gen5'
param sqlDatabaseFamily string = 'Gen5'

/// sqlDatabaseConfiguration
param sqlServerName string
param sqlDatabaseCpuCapacity string
param sqlDatabaseSizeBytes string
param licenseType string = 'LicenseIncluded'

/// sqlDatabaseMonitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: toLower(sqlServerName)
}

resource publicMaintenanceConfigurations 'Microsoft.Maintenance/publicMaintenanceConfigurations@2022-07-01-preview' existing = {
  scope: subscription()
  name: 'SQL_Default'
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: toLower(sqlDatabaseName)
  location: location
  tags: tags
  sku: {
    tier: sqlDatabaseTier
    name: sqlDatabaseSkuName
    family: sqlDatabaseFamily
    capacity: ((!empty(sqlDatabaseCpuCapacity)) ? int(sqlDatabaseCpuCapacity) : 2)
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: ((!empty(sqlDatabaseSizeBytes)) ? int(sqlDatabaseSizeBytes) : 10737418240)
    zoneRedundant: false
    licenseType: licenseType
    readScale: 'Enabled'
    highAvailabilityReplicaCount: 0
    requestedBackupStorageRedundancy: 'Geo'
    isLedgerOn: false
    maintenanceConfigurationId: publicMaintenanceConfigurations.id
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: sqlDatabase
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
