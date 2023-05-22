/*
.Synopsis
    Bicep template for Storage Account Containers. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/blobServices/containers?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.221128
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// storageAccountContainerParameters
param storageAccountName string
param containerName array

/// resources
resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: toLower('${storageAccountName}/default')
}

resource storageAccountContainerName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = [ for item in containerName: {
  name: toLower('${storageAccountName}/default/${item}')
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccountBlobService
  ]
}]
