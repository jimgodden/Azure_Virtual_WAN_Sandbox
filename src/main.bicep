@description('Azure Datacenter location that the main resouces will be deployed to.')
param mainLocation string = resourceGroup().location

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
    vHub_Iteration: 1
  }
}

module branchHub './modules/Networking/hubAll.bicep' = {
  name: 'branchHub'
  params: {
    location: branchLocation
    vwanID: VWAN.id
    vm_AdminUserName: vm_AdminUserName
    vm_AdminPassword: vm_AdminPassword
    vHub_Iteration: 2
  }
}
