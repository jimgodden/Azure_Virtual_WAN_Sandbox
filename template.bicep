param virtualWans_vwan_name string = 'vwan'
param virtualHubs_eus2hub_name string = 'eus2hub'
param firewallPolicies_AzFW_Policy_name string = 'AzFW_Policy'
param azureFirewalls_AzureFirewall_eus2hub_name string = 'AzureFirewall_eus2hub'
param vpnGateways_d6bb4daf422c40aba68833e213e85949_eastus2_gw_name string = 'd6bb4daf422c40aba68833e213e85949-eastus2-gw'

resource firewallPolicies_AzFW_Policy_name_resource 'Microsoft.Network/firewallPolicies@2022-07-01' = {
  name: firewallPolicies_AzFW_Policy_name
  location: 'eastus2'
  properties: {
    sku: {
      tier: 'Basic'
    }
    threatIntelMode: 'Off'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
  }
}

resource virtualWans_vwan_name_resource 'Microsoft.Network/virtualWans@2022-07-01' = {
  name: virtualWans_vwan_name
  location: 'eastus2'
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    office365LocalBreakoutCategory: 'None'
    type: 'Standard'
  }
}

resource virtualHubs_eus2hub_name_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  name: '${virtualHubs_eus2hub_name}/defaultRouteTable'
  properties: {
    routes: []
    labels: [
      'default'
    ]
  }
  dependsOn: [
    virtualHubs_eus2hub_name_resource
  ]
}

resource virtualHubs_eus2hub_name_noneRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  name: '${virtualHubs_eus2hub_name}/noneRouteTable'
  properties: {
    routes: []
    labels: [
      'none'
    ]
  }
  dependsOn: [
    virtualHubs_eus2hub_name_resource
  ]
}

resource vpnGateways_d6bb4daf422c40aba68833e213e85949_eastus2_gw_name_resource 'Microsoft.Network/vpnGateways@2022-07-01' = {
  name: vpnGateways_d6bb4daf422c40aba68833e213e85949_eastus2_gw_name
  location: 'eastus2'
  properties: {
    connections: []
    virtualHub: {
      id: virtualHubs_eus2hub_name_resource.id
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

resource azureFirewalls_AzureFirewall_eus2hub_name_resource 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: azureFirewalls_AzureFirewall_eus2hub_name
  location: 'eastus2'
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Basic'
    }
    additionalProperties: {}
    virtualHub: {
      id: virtualHubs_eus2hub_name_resource.id
    }
    hubIPAddresses: {
      privateIPAddress: '10.50.64.4'
      publicIPs: {
        addresses: [
          {
            address: '20.114.232.182'
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

resource virtualHubs_eus2hub_name_resource 'Microsoft.Network/virtualHubs@2022-07-01' = {
  name: virtualHubs_eus2hub_name
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
      id: vpnGateways_d6bb4daf422c40aba68833e213e85949_eastus2_gw_name_resource.id
    }
    azureFirewall: {
      id: azureFirewalls_AzureFirewall_eus2hub_name_resource.id
    }
    sku: 'Standard'
    routingState: 'Provisioned'
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'VpnGateway'
  }
}