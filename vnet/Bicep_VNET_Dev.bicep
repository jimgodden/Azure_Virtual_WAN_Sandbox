@description('Returns the location of the Resource Group')
param location string = resourceGroup().location

@description('Current Virtual Network Iteration')
@minValue(1)
@maxValue(9)
param vnetIteration int = 1

@description('Name of the Virtual Network')
param vnetName string = 'vnet${vnetIteration}'

@description('Address Prefix of the Virtual Network')
param vnetAddressPrefix string = '10.5${vnetIteration}.0.0/16'

// TODO - Figure out if it needs a Resource ID or some other way to connect the vhub from a separate file.  Possibly using "Existing".
@description('vHub something?')
param vhub string

@description('Address Prefix of the vHub Virtual Network')
param vhubAddressPrefix string = '10.10.0.0/16'

@description('Name of the Virtual Network')
param subnetName string = 'subnet${vnetIteration}'

@description('Address Prefix of the Subnet')
param subnetAddressPrefix string = '10.5${vnetIteration}.0.0/24'

@description('Name of the Network Security Group')
param defaultNSGName string = 'Default_NSG'

@description('Name of the Network Security Group Rule')
param defaultNSGRuleName string = 'rule${vnetIteration}'

@description('Name of the Network Security Group Rule')
param defaultNSGRulePriority string = '10${vnetIteration}'


resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    //virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource vhubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-09-01' = {
  parent: vnet
  name: 'RemoteVnetToHubPeering_${vnetIteration}'
  properties: {
    remoteVirtualNetwork: {
      id: vhub
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    doNotVerifyRemoteGateways: true
    remoteAddressSpace: {
      addressPrefixes: [
        vhubAddressPrefix
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        vhubAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: defaultNSGName
  location: location
  properties: {
  }
}

resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  parent: nsg
  name: defaultNSGRuleName
  properties: {
    description: 'test'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '10.0.0.1/32'
    destinationAddressPrefix: '10.5${vnetIteration}.0.4'
    access: 'Allow'
    priority: int(defaultNSGRulePriority)
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}
