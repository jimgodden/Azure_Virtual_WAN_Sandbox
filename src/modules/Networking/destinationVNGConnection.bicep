@description('Azure Datacenter that the resources are deployed to')
param location string

@description('Identifier for which vHub is being used')
param vhubIteration int

@description('Public IP Address of the first VPN Gateway Instance')
param gatewayIPAddress_0 string

@description('BGP Peering Address of the first VPN Gateway Instance')
param bgpPeeringAddress_0 string

@description('Public IP Address of the second VPN Gateway Instance')
param gatewayIPAddress_1 string

@description('BGP Peering Address of the second VPN Gateway Instance')
param bgpPeeringAddress_1 string

@description('VPN Shared Key used for authenticating VPN connections')
@secure()
param vpn_SharedKey string

@description('Existing Virtual Network Gateway ID')
param existingVNGID string

param rgName string = resourceGroup().name

resource connection0 'Microsoft.Network/connections@2022-11-01' = {
    name: '${rgName}_to_vhub_${vhubIteration}_0'
    location: location
    properties: {
      virtualNetworkGateway1: {
        id: existingVNGID
      }
      localNetworkGateway2: {
        id: lng0.id
      }
      connectionType: 'IPsec'
      connectionProtocol: 'IKEv2'
      routingWeight: 0
      sharedKey: vpn_SharedKey
      enableBgp: true
      useLocalAzureIpAddress: false 
      usePolicyBasedTrafficSelectors: false
      ipsecPolicies: [
        {
          saLifeTimeSeconds: 3600
          saDataSizeKilobytes: 102400000
          ipsecEncryption: 'AES256'
          ipsecIntegrity: 'SHA256'
          ikeEncryption: 'AES256'
          ikeIntegrity: 'SHA256'
          dhGroup: 'DHGroup14'
          pfsGroup: 'None'
        }
      ]
      dpdTimeoutSeconds: 45
      connectionMode: 'Default'
  }
}

resource connection1 'Microsoft.Network/connections@2022-11-01' = {
  name: '${rgName}_to_vhub_${vhubIteration}_1'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: existingVNGID
    }
    localNetworkGateway2: {
      id: lng1.id
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 0
    sharedKey: vpn_SharedKey
    enableBgp: true
    useLocalAzureIpAddress: false 
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: [
      {
        saLifeTimeSeconds: 3600
        saDataSizeKilobytes: 102400000
        ipsecEncryption: 'AES256'
        ipsecIntegrity: 'SHA256'
        ikeEncryption: 'AES256'
        ikeIntegrity: 'SHA256'
        dhGroup: 'DHGroup14'
        pfsGroup: 'None'
      }
    ]
    dpdTimeoutSeconds: 45
    connectionMode: 'Default'
}
}

resource lng0 'Microsoft.Network/localNetworkGateways@2022-11-01' = {
  name: '${rgName}_lng_tovhub_${vhubIteration}_0'
  location: location
  properties: {
    gatewayIpAddress: gatewayIPAddress_0
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: bgpPeeringAddress_0
    }
  }
}

resource lng1 'Microsoft.Network/localNetworkGateways@2022-11-01' = {
  name: '${rgName}_lng_tovhub_${vhubIteration}_1'
  location: location
  properties: {
    gatewayIpAddress: gatewayIPAddress_1
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: bgpPeeringAddress_1
    }
  }
}
