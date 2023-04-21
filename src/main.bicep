@description('Name of the Virtual WAN resource')
param VWAN_Name string = 'vwan'

@description('Current vHub Iteration')
@minValue(1)
@maxValue(9)
param vHubIteration int = 1

@description('Name of the first Virtual Hub within the Virtual WAN')
param vHub1_Name string = 'vhub${vHubIteration}'

@description('Address Prefix of the first Virtual Hub')
param vHub1_AddressPrefix string = '10.${vHubIteration}0.0.0/16'

@description('Name of the Azure Firewall within the Virtual Hub')
param AzFW_Name string = 'AzFW'

@description('Sku name of the Azure Firewall.  Allowed values are Basic, Standard, and Premium')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param AzFW_SKU string = 'Basic'

@description('Name of the Azure Firewall Policy')
param AzFWPolicy_Name string = 'AzFW_Policy'

@description('Name of the Azure Virtual Network Gateway')
param AzureVNG_Name string = 'vng'

@description('Azure Datacenter location that all of the resouces will be deployed to.')
param location string = resourceGroup().location



@description('Current Virtual Network Iteration')
@minValue(1)
@maxValue(9)
param vnetIteration int = 1

@description('Name of the Virtual Network')
param vnetName string = 'vnet${vnetIteration}'

@description('Address Prefix of the Virtual Network')
param vnetAddressPrefix string = '10.5${vnetIteration}.0.0/16'

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


resource VWAN 'Microsoft.Network/virtualWans@2022-07-01' = {
  name: VWAN_Name
  location: location
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

resource vHub 'Microsoft.Network/virtualHubs@2022-07-01' = {
  name: vHub1_Name
  location: location
  properties: {
    addressPrefix: vHub1_AddressPrefix
    virtualWan: {
      id: VWAN.id
    }
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'VpnGateway'
  }
}


resource vHub_RouteTable_Default 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  parent: vHub
  name: 'defaultRouteTable'
  properties: {
    routes: []
    labels: [
      'default'
    ]
  }
}

resource vHub_RouteTable_None 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  parent: vHub
  name: 'noneRouteTable'
  properties: {
    routes: []
    labels: [
      'none'
    ]
  }
}

// TODO Start - Clean up and verify
resource vHubVNetConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-09-01' = {
  parent: vHub
  name: 'test1'
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: vHub_RouteTable_Default.id
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: vHub_RouteTable_Default.id
          }
        ]
      }
      vnetRoutes: {
        staticRoutes: []
        staticRoutesConfig: {
          vnetLocalRouteOverrideCriteria: 'Contains'
        }
      }
    }
    remoteVirtualNetwork: {
      id: vnet.id
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}
// TODO End

resource AzureVNG 'Microsoft.Network/vpnGateways@2022-07-01' = {
  name: AzureVNG_Name
  location: location
  properties: {
    connections: []
    virtualHub: {
      id: vHub.id
    }
    vpnGatewayScaleUnit: 1
    natRules: []
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource AzFW_Policy 'Microsoft.Network/firewallPolicies@2022-07-01' = {
  name: AzFWPolicy_Name
  location: location
  properties: {
    sku: {
      tier: AzFW_SKU
    }
  }
}

resource AzFW 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: AzFW_Name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'AzFW_Hub'
      tier: AzFW_SKU
    }
    additionalProperties: {}
    virtualHub: {
      id: vHub.id
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    firewallPolicy: {
      id: AzFW_Policy.id
    }
  }
}



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
      id: vHub.id
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
