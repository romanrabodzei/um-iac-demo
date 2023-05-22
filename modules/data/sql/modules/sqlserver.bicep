/*
.Synopsis
    Bicep template for SQL Server. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/servers?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221214
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// sqlServerParameters
param location string
param sqlServerName string

/// sqlServerAuthentication
param AADGroupName string
param AADGroupSid string

/// tags
param tags object

/// resources
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: toLower(sqlServerName)
  location: location
  tags: tags
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      login: AADGroupName
      sid: AADGroupSid
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true
      principalType: 'Group'
    }
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
  resource auditsettings 'auditingSettings' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      isDevopsAuditEnabled: true
      retentionDays: 30
      auditActionsAndGroups: [
        'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
        'FAILED_DATABASE_AUTHENTICATION_GROUP'
        'BATCH_COMPLETED_GROUP'
      ]
      state: 'Enabled'
    }
  }
  resource allowAllWindowsAzureIps 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

output sqlServerId string = sqlServer.id
