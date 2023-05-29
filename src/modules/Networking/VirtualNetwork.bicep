@description('Azure Datacenter that the resource is deployed to')
param location string

@description('Name of the Virtual Network')
param vnet_Name string

@description('Address Prefix of the Virtual Network')
param vnet_AddressPrefix string

@description('Name of the Virtual Network')
param subnet_Name string

@description('Address Prefix of the Subnet')
param subnet_AddressPrefix string

@description('Name of the Network Security Group')
param defaultNSG_Name string

// @description('Name of the Network Security Group Rule')
// param defaultNSG_RuleName string

// @description('Name of the Network Security Group Rule')
// param defaultNSG_RulePriority string


resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnet_Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_AddressPrefix
      ]
    }
    enableDdosProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: subnet_Name
  properties: {
    addressPrefix: subnet_AddressPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: defaultNSG_Name
  location: location
  properties: {
  }
}

// resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
//   parent: nsg
//   name: defaultNSG_RuleName
//   properties: {
//     description: 'test'
//     protocol: '*'
//     sourcePortRange: '*'
//     destinationPortRange: '8080'
//     sourceAddressPrefix: '10.0.0.1/32'
//     destinationAddressPrefix: '*'
//     access: 'Allow'
//     priority: int(defaultNSG_RulePriority)
//     direction: 'Inbound'
//     sourcePortRanges: []
//     destinationPortRanges: []
//     sourceAddressPrefixes: []
//     destinationAddressPrefixes: []
//   }
// }
