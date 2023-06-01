/*
.Synopsis
    Bicep template for Service Bus. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.ServiceBus/namespaces?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabodzei
    Version    : 1.0.230213
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// serviceBusParameters
param primaryNamespaceName string 
param secondaryNamespaceName string 
param secondaryNamespaceResourceGroupName string
param serviceBusLinkName string

/// resources
resource secondaryServiceBus_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  scope: resourceGroup(secondaryNamespaceResourceGroupName)
  name: secondaryNamespaceName
}

resource primaryNamespaceName_aliasId 'Microsoft.ServiceBus/namespaces/disasterrecoveryconfigs@2022-10-01-preview' = {
  name: '${primaryNamespaceName}/${serviceBusLinkName}'
  properties: {
    partnerNamespace: secondaryServiceBus_resource.id
  }
}
