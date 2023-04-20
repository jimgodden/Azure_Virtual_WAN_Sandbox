param virtualNetworks_vnet1_name string
param virtualNetworks_vnet2_name string
param networkSecurityGroups_Default_NSG_name string
param virtualNetworks_HV_vhub1_6d1cd796_6a1f_4ebb_a426_c5e8ce80e129_externalid string

resource networkSecurityGroups_Default_NSG_name_resource 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: networkSecurityGroups_Default_NSG_name
  location: 'eastus2'
  properties: {
    securityRules: [
      {
        name: 'rule2'
        id: networkSecurityGroups_Default_NSG_name_rule2.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'test'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.0.1/32'
          destinationAddressPrefix: '10.52.0.4'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_Default_NSG_name_rule2 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: '${networkSecurityGroups_Default_NSG_name}/rule2'
  properties: {
    description: 'test'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '10.0.0.1/32'
    destinationAddressPrefix: '10.52.0.4'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_Default_NSG_name_resource
  ]
}

resource virtualNetworks_vnet1_name_RemoteVnetToHubPeering_2156ff51_91b0_4a39_8ee6_39531ab2dac8 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-09-01' = {
  name: '${virtualNetworks_vnet1_name}/RemoteVnetToHubPeering_2156ff51-91b0-4a39-8ee6-39531ab2dac8'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_HV_vhub1_6d1cd796_6a1f_4ebb_a426_c5e8ce80e129_externalid
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    doNotVerifyRemoteGateways: true
    remoteAddressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet1_name_resource
  ]
}

resource virtualNetworks_vnet2_name_RemoteVnetToHubPeering_2156ff51_91b0_4a39_8ee6_39531ab2dac8 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-09-01' = {
  name: '${virtualNetworks_vnet2_name}/RemoteVnetToHubPeering_2156ff51-91b0-4a39-8ee6-39531ab2dac8'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_HV_vhub1_6d1cd796_6a1f_4ebb_a426_c5e8ce80e129_externalid
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    doNotVerifyRemoteGateways: true
    remoteAddressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet2_name_resource
  ]
}

resource virtualNetworks_vnet1_name_subnet1 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  name: '${virtualNetworks_vnet1_name}/subnet1'
  properties: {
    addressPrefix: '10.51.0.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_Default_NSG_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet1_name_resource
  ]
}

resource virtualNetworks_vnet2_name_subnet2 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  name: '${virtualNetworks_vnet2_name}/subnet2'
  properties: {
    addressPrefix: '10.52.0.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_Default_NSG_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet2_name_resource
  ]
}

resource virtualNetworks_vnet1_name_resource 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: virtualNetworks_vnet1_name
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.51.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet1'
        id: virtualNetworks_vnet1_name_subnet1.id
        properties: {
          addressPrefix: '10.51.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_Default_NSG_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'RemoteVnetToHubPeering_2156ff51-91b0-4a39-8ee6-39531ab2dac8'
        id: virtualNetworks_vnet1_name_RemoteVnetToHubPeering_2156ff51_91b0_4a39_8ee6_39531ab2dac8.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_HV_vhub1_6d1cd796_6a1f_4ebb_a426_c5e8ce80e129_externalid
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: false
          allowGatewayTransit: false
          useRemoteGateways: true
          doNotVerifyRemoteGateways: true
          remoteAddressSpace: {
            addressPrefixes: [
              '10.50.0.0/16'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '10.50.0.0/16'
            ]
          }
        }
        type: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
      }
    ]
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet2_name_resource 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: virtualNetworks_vnet2_name
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.52.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet2'
        id: virtualNetworks_vnet2_name_subnet2.id
        properties: {
          addressPrefix: '10.52.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_Default_NSG_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'RemoteVnetToHubPeering_2156ff51-91b0-4a39-8ee6-39531ab2dac8'
        id: virtualNetworks_vnet2_name_RemoteVnetToHubPeering_2156ff51_91b0_4a39_8ee6_39531ab2dac8.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_HV_vhub1_6d1cd796_6a1f_4ebb_a426_c5e8ce80e129_externalid
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: false
          allowGatewayTransit: false
          useRemoteGateways: true
          doNotVerifyRemoteGateways: true
          remoteAddressSpace: {
            addressPrefixes: [
              '10.50.0.0/16'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '10.50.0.0/16'
            ]
          }
        }
        type: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
      }
    ]
    enableDdosProtection: false
  }
}