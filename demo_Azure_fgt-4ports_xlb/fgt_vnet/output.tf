output "vnet" {
  value = {
    name = azurerm_virtual_network.vnet-fgt.name
    id   = azurerm_virtual_network.vnet-fgt.id
  }
}

output "vnet_names" {
  value = {
    vnet-fgt = azurerm_virtual_network.vnet-fgt.name
  }
}

output "subnet_cidrs" {
  value = {
    mgmt    = azurerm_subnet.subnet-mgmt.address_prefixes[0]
    public  = azurerm_subnet.subnet-public.address_prefixes[0]
    private = azurerm_subnet.subnet-private.address_prefixes[0]
    ha      = azurerm_subnet.subnet-ha.address_prefixes[0]
  }
}

output "subnet_names" {
  value = {
    mgmt    = azurerm_subnet.subnet-mgmt.name
    public  = azurerm_subnet.subnet-public.name
    private = azurerm_subnet.subnet-private.name
    ha      = azurerm_subnet.subnet-ha.name
  }
}

output "subnet_ids" {
  value = {
    mgmt    = azurerm_subnet.subnet-mgmt.id
    public  = azurerm_subnet.subnet-public.id
    private = azurerm_subnet.subnet-private.id
    ha      = azurerm_subnet.subnet-ha.id
  }
}