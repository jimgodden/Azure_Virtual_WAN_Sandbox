@description('Azure Datacenter location that the main resouces will be deployed to.')
param mainLocation string = resourceGroup().location

@description('Azure Datacenter location that the branch resouces will be deployed to.')
param branchLocation string = 'westus2'

@description('Deploys a vHub in another location for multi region connectivity')
param multiRegion bool = true

// VWAN Start
@description('Name of the Virtual WAN resource')
param VWAN_Name string = 'vwan'

@description('Admin Username for the Virtual Machine')
param vm_AdminUserName string

@description('Password for the Virtual Machine Admin User')
@secure()
param vm_AdminPassword string

@description('VPN Shared Key used for authenticating VPN connections')
@secure()
param vpn_SharedKey string

@description('Existing Virtual Network Gateway ID')
param existingVNGID string


resource VWAN 'Microsoft.Network/virtualWans@2022-07-01' = {
  name: VWAN_Name
  location: mainLocation
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

module mainHub './modules/Networking/hubAndContents.bicep' = {
  name: 'mainHub'
  params: {
    location: mainLocation
    vwanID: VWAN.id
    vm_AdminUserName: vm_AdminUserName
    vm_AdminPassword: vm_AdminPassword
    vpn_SharedKey: vpn_SharedKey
    vHub_Iteration: 1
    usingVPN: true
    usingAzFW: true
  }
}

module MainvHubVNetConn_1 './modules/Networking/hubVirtualNetworkConnections.bicep' = {
  name: 'Main_vHub_to_vnet1_Conn'
  params: {
    vHubName: mainHub.outputs.vHubName
    vHubRouteTableDefaultID: mainHub.outputs.vHubRouteTableDefaultID
    vnetID: mainHub.outputs.vnetID1
    vnetName: mainHub.outputs.vnetName1
  }
}

module ConnectionToMainHubVPN 'modules/Networking/destinationVNGConnection.bicep' = {
  name: 'ConnectionToMainHubVPN'
  params: {
    bgpPeeringAddress_0: mainHub.outputs.vpnBGPIP0
    bgpPeeringAddress_1: mainHub.outputs.vpnBGPIP1
    gatewayIPAddress_0: mainHub.outputs.vpnPubIP0
    gatewayIPAddress_1: mainHub.outputs.vpnPubIP1
    location: mainLocation
    vhubIteration: 1
    existingVNGID: existingVNGID
    vpn_SharedKey: vpn_SharedKey
  }
}

module branchHub './modules/Networking/hubAndContents.bicep' = if (multiRegion) {
  name: 'branchHub1'
  params: {
    location: branchLocation
    vwanID: VWAN.id
    vm_AdminUserName: vm_AdminUserName
    vm_AdminPassword: vm_AdminPassword
    vpn_SharedKey: vpn_SharedKey
    vHub_Iteration: 2
    usingVPN: false
    usingAzFW: false
  }
}

module BranchvHubVNetConn_1_1 './modules/Networking/hubVirtualNetworkConnections.bicep' = {
  name: 'Branch1_vHub_to_vnet1_Conn'
  params: {
    vHubName: branchHub.outputs.vHubName
    vHubRouteTableDefaultID: branchHub.outputs.vHubRouteTableDefaultID
    vnetID: branchHub.outputs.vnetID1
    vnetName: branchHub.outputs.vnetName1
  }
  // The connection fails if it is deployed when Bicep deems possible.
  // This dependsOn ensures that it is deployed long after the resources are ready
  dependsOn: [
    ConnectionToMainHubVPN
  ]
}
