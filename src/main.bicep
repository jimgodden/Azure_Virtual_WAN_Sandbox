@description('Name of the Virtual WAN resource')
param VWAN_Name string = 'vwan'

@description('Name of the first Virtual Hub within the Virtual WAN')
param vHub1_Name string = 'vhub'

@description('Address Prefix of the first Virtual Hub')
param vHub1_AddressPrefix string = '10.50.0.0/16'

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
    // virtualHubRouteTableV2s: []
    addressPrefix: vHub1_AddressPrefix
    
    // virtualRouterAsn: 65515
    // routeTable: {
    //   routes: []
    // }
    // virtualRouterAutoScaleConfiguration: {
    //   minCapacity: 2
    // }
    virtualWan: {
      id: VWAN.id
    }
    // azureFirewall: {
      
    //   id: AzFW.id
    // }
    // sku: 'Standard'
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'VpnGateway'
  }
}


resource vHub_RouteTable_Default 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  //parent: virtualHubs_eus2hub_name_resource
  name: '${vHub1_Name}/defaultRouteTable'
  properties: {
    routes: []
    labels: [
      'default'
    ]
  }
  dependsOn: [
    vHub
  ]
}

resource vHub_RouteTable_None 'Microsoft.Network/virtualHubs/hubRouteTables@2022-07-01' = {
  name: '${vHub1_Name}/noneRouteTable'
  properties: {
    routes: []
    labels: [
      'none'
    ]
  }
  dependsOn: [
    vHub
  ]
}

resource AzureVNG 'Microsoft.Network/vpnGateways@2022-07-01' = {
  name: AzureVNG_Name
  location: location
  properties: {
    connections: []
    virtualHub: {
      id: vHub.id
    }
    // bgpSettings: {
    //   asn: 65515
    //   peerWeight: 0
    //   bgpPeeringAddresses: [
    //     {
    //       ipconfigurationId: 'Instance0'
    //       customBgpIpAddresses: []
    //     }
    //     {
    //       ipconfigurationId: 'Instance1'
    //       customBgpIpAddresses: []
    //     }
    //   ]
    // }
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
    // threatIntelMode: 'Off'
    // threatIntelWhitelist: {
    //   fqdns: []
    //   ipAddresses: []
    // }
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
