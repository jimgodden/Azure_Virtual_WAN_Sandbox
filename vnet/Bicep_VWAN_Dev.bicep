param vpnGateways_vng_name string
param virtualWans_vwan_name string
param virtualHubs_vhub1_name string
param azureFirewalls_AzFW_name string
param firewallPolicies_AzFW_Policy_name string
param virtualNetworks_vnet1_externalid string
param virtualNetworks_vnet2_externalid string

resource firewallPolicies_AzFW_Policy_name_resource 'Microsoft.Network/firewallPolicies@2022-09-01' = {
  name: firewallPolicies_AzFW_Policy_name
  location: 'eastus2'
  properties: {
    sku: {
      tier: 'Basic'
    }
    threatIntelMode: 'Alert'
  }
}

resource virtualWans_vwan_name_resource 'Microsoft.Network/virtualWans@2022-09-01' = {
  name: virtualWans_vwan_name
  location: 'eastus2'
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    office365LocalBreakoutCategory: 'None'
    type: 'Standard'
  }
}

resource virtualHubs_vhub1_name_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-09-01' = {
  name: '${virtualHubs_vhub1_name}/defaultRouteTable'
  properties: {
    routes: []
    labels: [
      'default'
    ]
  }
  dependsOn: [
    virtualHubs_vhub1_name_resource
  ]
}

resource virtualHubs_vhub1_name_noneRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-09-01' = {
  name: '${virtualHubs_vhub1_name}/noneRouteTable'
  properties: {
    routes: []
    labels: [
      'none'
    ]
  }
  dependsOn: [
    virtualHubs_vhub1_name_resource
  ]
}

resource vpnGateways_vng_name_resource 'Microsoft.Network/vpnGateways@2022-09-01' = {
  name: vpnGateways_vng_name
  location: 'eastus2'
  properties: {
    connections: []
    virtualHub: {
      id: virtualHubs_vhub1_name_resource.id
    }
    bgpSettings: {
      asn: 65515
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: 'Instance0'
          customBgpIpAddresses: []
        }
        {
          ipconfigurationId: 'Instance1'
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayScaleUnit: 1
    natRules: []
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource azureFirewalls_AzFW_name_resource 'Microsoft.Network/azureFirewalls@2022-09-01' = {
  name: azureFirewalls_AzFW_name
  location: 'eastus2'
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Basic'
    }
    additionalProperties: {}
    virtualHub: {
      id: virtualHubs_vhub1_name_resource.id
    }
    hubIPAddresses: {
      privateIPAddress: '10.50.64.4'
      publicIPs: {
        addresses: [
          {
            address: '20.65.66.134'
          }
        ]
        count: 1
      }
    }
    firewallPolicy: {
      id: firewallPolicies_AzFW_Policy_name_resource.id
    }
  }
}

resource virtualHubs_vhub1_name_test1 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-09-01' = {
  name: '${virtualHubs_vhub1_name}/test1'
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHubs_vhub1_name_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: virtualHubs_vhub1_name_defaultRouteTable.id
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
      id: virtualNetworks_vnet1_externalid
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualHubs_vhub1_name_resource
  ]
}

resource virtualHubs_vhub1_name_test2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-09-01' = {
  name: '${virtualHubs_vhub1_name}/test2'
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHubs_vhub1_name_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: virtualHubs_vhub1_name_defaultRouteTable.id
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
      id: virtualNetworks_vnet2_externalid
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualHubs_vhub1_name_resource
  ]
}

resource virtualHubs_vhub1_name_resource 'Microsoft.Network/virtualHubs@2022-09-01' = {
  name: virtualHubs_vhub1_name
  location: 'eastus2'
  properties: {
    virtualHubRouteTableV2s: []
    addressPrefix: '10.50.0.0/16'
    virtualRouterAsn: 65515
    virtualRouterIps: [
      '10.50.32.4'
      '10.50.32.5'
    ]
    routeTable: {
      routes: []
    }
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
    virtualWan: {
      id: virtualWans_vwan_name_resource.id
    }
    vpnGateway: {
      id: vpnGateways_vng_name_resource.id
    }
    azureFirewall: {
      id: azureFirewalls_AzFW_name_resource.id
    }
    routingState: 'Provisioned'
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'VpnGateway'
  }
}