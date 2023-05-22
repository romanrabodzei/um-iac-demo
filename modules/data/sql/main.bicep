/*
.Synopsis
    Main Bicep template for data services: sql servers, sql databases and sql replicas

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230522

           _
       .__(.)<  (MEOW)
        \___)
~~~~~~~~~~~~~~~~~~~~~~~~
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Deployment scope /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Parameters and variables ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

param variables object
param location string

param resourceGroupNameUKS string
param resourceGroupNameUKW string = ''

param tags object

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource resourceGroupUKS 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: resourceGroupNameUKS
}

resource resourceGroupUKW 'Microsoft.Resources/resourceGroups@2022-09-01' existing = if (!empty(resourceGroupNameUKW)) {
  scope: subscription()
  name: resourceGroupNameUKW
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// SQL Servers /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var sqlServers = {
  NPD: [
    {
      // 0
      deploymentName: 'sqlServer001-${variables.global.environmentName}'
      sqlServerName: variables.npd.sqlServerNameNPD001
    }
  ]
  PRE: [
    {
      // 0
      deploymentName: 'sqlServer001-${variables.global.environmentName}'
      sqlServerName: variables.pre.sqlServerNamePRE001
    }
  ]
  PRD: [
    {
      // 0
      deploymentName: (location == 'uksouth') ? 'sqlServer001-${variables.global.environmentName}' : 'sqlServer002-${location}-${variables.global.environmentName}'
      sqlServerName: (location == 'uksouth') ? variables.prd.uksouth.sqlServerNamePROD001 : variables.prd.ukwest.sqlServerNameDRPROD002
    }
  ]
}

@description('SQL server')
module sqlServer_resource 'modules/sqlserver.bicep' = [for sqlServer in sqlServers[variables.global.environmentName]: {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(sqlServer.deploymentName)
  params: {
    location: location
    sqlServerName: sqlServer.sqlServerName
    AADGroupName: variables.global.AADGroupName
    AADGroupSid: variables.global.AADGroupSid
    tags: tags
  }
  dependsOn: []
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// SQL Databases ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var sqlDatabases = {
  NPD: [
    {
      // 0
      deploymentName: 'sqlDatabaseNPD001-${variables.global.environmentName}'
      sqlServerName: variables.npd.sqlServerNameNPD001
      sqlDatabaseName: variables.npd.sqlDatabaseNameNPD001
      sqlDatabaseCpuCapacity: variables.npd.sqlDatabaseCpuCapacityNPD001
      sqlDatabaseSizeBytes: variables.npd.sqlDatabaseSizeBytesNPD001
    }
  ]
  PRE: [
    {
      // 0
      deploymentName: 'sqlDatabasePRE001-${variables.global.environmentName}'
      sqlServerName: variables.pre.sqlServerNamePRE001
      sqlDatabaseName: variables.pre.sqlDatabaseNamePRE001
      sqlDatabaseCpuCapacity: variables.pre.sqlDatabaseCpuCapacityPRE001
      sqlDatabaseSizeBytes: variables.pre.sqlDatabaseSizeBytesPRE001
    }
  ]
  PRD: [
    {
      // 0
      deploymentName: 'sqlDatabasePROD001-${variables.global.environmentName}'
      sqlServerName: variables.prd.uksouth.sqlServerNamePROD001
      sqlDatabaseName: variables.prd.global.sqlDatabaseNamePROD001
      sqlDatabaseCpuCapacity: variables.prd.global.sqlDatabaseCpuCapacityPROD001
      sqlDatabaseSizeBytes: variables.prd.global.sqlDatabaseSizeBytesPROD001
    }
  ]
}

@batchSize(5)
@description('SQL database')
module sqlDatabase_resource 'modules/sqldatabase.bicep' = [for sqlDatabase in sqlDatabases[variables.global.environmentName]: if (location == 'uksouth') {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(sqlDatabase.deploymentName)
  params: {
    location: location
    sqlServerName: toLower(sqlDatabase.sqlServerName)
    sqlDatabaseName: toLower(sqlDatabase.sqlDatabaseName)
    sqlDatabaseCpuCapacity: sqlDatabase.sqlDatabaseCpuCapacity
    sqlDatabaseSizeBytes: sqlDatabase.sqlDatabaseSizeBytes
    licenseType: variables.global.sqlLicenseType
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: [
    sqlServer_resource
  ]
}]

var sqlDatabaseReplicas = {
  PRD: [
    {
      // 0
      deploymentName: 'sqlDatabasePROD001-Replica-${location}-${variables.global.environmentName}'
      sqlServerName: variables.prd.ukwest.sqlServerNameDRPROD002
      sqlDatabaseName: variables.prd.global.sqlDatabaseNamePROD001
      sourceSqlDatabaseResourceGroupName: variables.prd.uksouth.resourceGroupName[0]
      sourcesqlServerName: variables.prd.uksouth.sqlServerNamePROD001
      sourceSqlDatabaseName: variables.prd.global.sqlDatabaseNamePROD001
    }
  ]
}

@batchSize(5)
@description('SQL database')
module sqlDatabaseReplica_resource 'modules/sqldatabase_replica.bicep' = [for sqlDatabaseReplica in sqlDatabaseReplicas.PRD: if (location == 'ukwest') {
  scope: resourceGroupUKW
  name: toLower(sqlDatabaseReplica.deploymentName)
  params: {
    location: location
    sqlServerName: toLower(sqlDatabaseReplica.sqlServerName)
    sqlDatabaseName: toLower(sqlDatabaseReplica.sqlDatabaseName)
    sourceSqlDatabaseResourceGroupName: sqlDatabaseReplica.sourceSqlDatabaseResourceGroupName
    sourcesqlServerName: toLower(sqlDatabaseReplica.sourcesqlServerName)
    sourceSqlDatabaseName: toLower(sqlDatabaseReplica.sourceSqlDatabaseName)
    licenseType: variables.global.sqlLicenseType
    logAnalyticsWorkspaceName: variables.umsUss.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: variables.umsUss.resourceGroupName
    tags: tags
  }
  dependsOn: [
    sqlServer_resource
  ]
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// SQL Failover group ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module failoverGroup_resource 'modules/slq_failovergroup.bicep' = if (location == 'ukwest') {
  scope: resourceGroupUKS
  name: 'sqlFailOverGroup-${variables.global.environmentName}'
  params: {
    location: location
    failoverGroupName: variables.prd.global.sqlFailoverGroupName
    partnerSqlServer: variables.prd.ukwest.sqlServerNameDRPROD002
    primarySqlServer: variables.prd.uksouth.sqlServerNamePROD001
    partnerSqlServerResourceGroupName: resourceGroupNameUKW
    sqlDatabaseName: variables.prd.global.sqlDatabaseNamePROD001
  }
  dependsOn: [
    sqlServer_resource
    sqlDatabaseReplica_resource
  ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// Private Endpoints ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

var privateEndpoints = {
  NPD: [
    {
      deploymentName: 'sqlServer001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.npd.sqlServerNameNPD001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Sql/servers/${variables.npd.sqlServerNameNPD001}'
      privateLinkServiceGroupIds: 'sqlServer'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-database-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-database-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName10}'
    }
  ]
  PRE: [
    {
      deploymentName: 'sqlServer001_pe01-${variables.global.environmentName}'
      privateEndpointName: '${variables.pre.sqlServerNamePRE001}-pe-001'
      privateLinkServiceId: '${resourceGroupUKS.id}/providers/Microsoft.Sql/servers/${variables.pre.sqlServerNamePRE001}'
      privateLinkServiceGroupIds: 'sqlServer'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-database-windows-net'
          properties: {
            privateDnsZoneId: '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-database-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName10}'
    }
  ]
  PRD: [
    {
      deploymentName: (location == 'uksouth') ? 'sqlServer001_pe01-${variables.global.environmentName}' : 'sqlServer002_pe02-${location}-${variables.global.environmentName}'
      privateEndpointName: (location == 'uksouth') ? '${variables.prd.uksouth.sqlServerNamePROD001}-pe-001' : '${variables.prd.ukwest.sqlServerNameDRPROD002}-pe-002'
      privateLinkServiceId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Sql/servers/${variables.prd.uksouth.sqlServerNamePROD001}' : '${resourceGroupUKW.id}/providers/Microsoft.Sql/servers/${variables.prd.ukwest.sqlServerNameDRPROD002}'
      privateLinkServiceGroupIds: 'sqlServer'
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-database-windows-net'
          properties: {
            privateDnsZoneId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-database-windows-net', '-', '.')}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/privateDnsZones/${replace('privatelink-database-windows-net', '-', '.')}'
          }
        }
      ]
      virtualNetworkSubnetId: (location == 'uksouth') ? '${resourceGroupUKS.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName10}' : '${resourceGroupUKW.id}/providers/Microsoft.Network/virtualNetworks/${variables.global.virtualNetworkName}/subnets/${variables.global.virtualNetworkSubnetName10}'
    }
  ]
}

@description('Private endpoints')
module privateEndpoint_resource_uksouth '../../network/modules/privateendpoint.bicep' = [for privateEndpoint in privateEndpoints[variables.global.environmentName]: {
  scope: resourceGroup((location == 'uksouth') ? resourceGroupNameUKS : resourceGroupNameUKW)
  name: toLower(privateEndpoint.deploymentName)
  params: {
    location: location
    privateEndpointName: toLower(privateEndpoint.privateEndpointName)
    privateLinkServiceId: privateEndpoint.privateLinkServiceId
    privateLinkServiceGroupIds: privateEndpoint.privateLinkServiceGroupIds
    virtualNetworkSubnetId: privateEndpoint.virtualNetworkSubnetId
    privateDnsZoneConfigs: privateEndpoint.privateDnsZoneConfigs
    tags: tags
  }
  dependsOn: [
    sqlServer_resource
  ]
}]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Outputs /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
