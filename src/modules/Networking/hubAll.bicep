@description('Azure Datacenter location that the main resouces will be deployed to.')
param location string = resourceGroup().location

@description('ID of the existing VWAN')
param vwanID string

@description('Current vHub Iteration')
@minValue(1)
@maxValue(9)
param vHub_Iteration int = 1

// vHub A
@description('Name of the first Virtual Hub within the Virtual WAN')
param vHub_Name string = 'vhub${vHub_Iteration}'

@description('Address Prefix of the first Virtual Hub')
param vHub_AddressPrefix string = '10.${vHub_Iteration}0.0.0/16'

@description('Name of the Azure Firewall within the vHub A')
param AzFW_Name string = 'AzFW${vHub_Iteration}'

@description('Sku name of the Azure Firewall.  Allowed values are Basic, Standard, and Premium')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param AzFW_SKU string = 'Basic'

@description('Name of the Azure Firewall Policy')
param AzFWPolicy_Name string = 'AzFW_Policy${vHub_Iteration}'

@description('Name of the Azure Virtual Network Gateway in vHub A')
param AzureVNG_Name string = 'vng${vHub_Iteration}'

// VNET Start
@description('Current Virtual Network Iteration')
@minValue(1)
@maxValue(9)
param vnet_Iteration int = 1



@description('Name of the Virtual Network')
param vnet_Name string = 'vnet_${vHub_Iteration}_${vnet_Iteration}'

@description('Address Prefix of the Virtual Network')
param vnet_AddressPrefix string = '10.${vHub_Iteration}${vnet_Iteration}.0.0/16'

@description('Name of the Virtual Network')
param subnet_Name string = 'subnet${vnet_Iteration}'

@description('Address Prefix of the Subnet')
param subnet_AddressPrefix string = '10.${vHub_Iteration}${vnet_Iteration}.0.0/24'

@description('Name of the Network Security Group')
param defaultNSG_Name string = 'Default_NSG${vHub_Iteration}'

@description('Name of the Network Security Group Rule')
param defaultNSG_RuleName string = 'rule${vnet_Iteration}'

@description('Name of the Network Security Group Rule')
param defaultNSG_RulePriority string = '10${vnet_Iteration}'

resource vHub 'Microsoft.Network/virtualHubs@2022-07-01' = {
  name: vHub_Name
  location: location
  properties: {
    addressPrefix: vHub_AddressPrefix
    virtualWan: {
      id: vwanID
    }
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'VpnGateway'
  }
}

resource vHubVNetConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-09-01' = {
  parent: vHub
  name: '${vHub_Name}_to_${vnet_Name}'
  dependsOn: [
    AzureVNG
  ]
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
  name: vnet_Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_AddressPrefix
      ]
    }
    enableDdosProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: subnet_Name
  properties: {
    addressPrefix: subnet_AddressPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: defaultNSG_Name
  location: location
  properties: {
  }
}

resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  parent: nsg
  name: defaultNSG_RuleName
  properties: {
    description: 'test'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '10.0.0.1/32'
    destinationAddressPrefix: '10.5${vnet_Iteration}.0.4'
    access: 'Allow'
    priority: int(defaultNSG_RulePriority)
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}





//  TESTING

@description('Name of the Virtual Machine')
param vm_Name string = 'testvm${vHub_Iteration}'

@description('Admin Username for the Virtual Machine')
param vm_AdminUserName string

@description('Password for the Virtual Machine Admin User')
@secure()
param vm_AdminPassword string

@description('Name of the Virtual Machines Network Interface')
param nic_Name string = '${vm_Name}_nic1'

resource nic 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: nic_Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vm_Name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_Name}_OsDisk_1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
          // id: resourceId('Microsoft.Compute/disks', '${vm_Name}_OsDisk_1')
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: vm_Name
      adminUsername: vm_AdminUserName
      adminPassword: vm_AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource vm_NetworkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: vm
  name: 'AzureNetworkWatcherExtension'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
  }
}

