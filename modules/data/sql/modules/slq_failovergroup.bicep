/*
.Synopsis
    Bicep template for SQL Failover Groups. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/servers/failoverGroups?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230522
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// sql FailOverGroup Parameters
param location string
param failoverGroupName string

/// sql Servers and DB information
param primarySqlServer string
param partnerSqlServer string
param partnerSqlServerResourceGroupName string
param sqlDatabaseName string

/// resources
resource sqlServerPrimary 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: toLower(primarySqlServer)
}

resource sqlServerPartner 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  scope: resourceGroup(partnerSqlServerResourceGroupName)
  name: toLower(partnerSqlServer)
}

resource failoverGroup 'Microsoft.Sql/servers/failoverGroups@2022-05-01-preview' = {
  parent: sqlServerPrimary
  name: toLower(failoverGroupName)
  properties: {
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    partnerServers: [
      {
        id: sqlServerPartner.id
      }
    ]
    databases: [
      resourceId('Microsoft.Sql/servers/databases', primarySqlServer, sqlDatabaseName)
    ]
  }
}
