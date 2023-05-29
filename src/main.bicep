@description('Azure Datacenter location that the main resouces will be deployed to.')
param mainLocation string = resourceGroup().location

@description('Deploys a vHub in another location for multi region connectivity')
param multiRegion bool = true

@description('Azure Datacenter location that the branch resouces will be deployed to.')
param branchLocation string = 'westus2'

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

resource VWAN 'Microsoft.Network/virtualWans@2022-07-01' = {
  name: VWAN_Name
  location: mainLocation
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

module mainHub './modules/Networking/hubAll.bicep' = {
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

module branchHub './modules/Networking/hubAll.bicep' = if (multiRegion) {
  name: 'branchHub'
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
