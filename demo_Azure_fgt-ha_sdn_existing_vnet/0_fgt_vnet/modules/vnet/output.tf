output "vnet" {
  value = {
    name = azurerm_virtual_network.vnet-fgt.name
    id   = azurerm_virtual_network.vnet-fgt.id
  }
}

output "subnet_cidrs" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.address_prefixes[0]
    public  = azurerm_subnet.subnet-public.address_prefixes[0]
    private = azurerm_subnet.subnet-private.address_prefixes[0]
    protected = azurerm_subnet.subnet-protected.address_prefixes[0]
  }
}

output "subnet_names" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.name
    public  = azurerm_subnet.subnet-public.name
    private = azurerm_subnet.subnet-private.name
    protected = azurerm_subnet.subnet-protected.name
  }
}

output "subnet_ids" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.id
    public  = azurerm_subnet.subnet-public.id
    private = azurerm_subnet.subnet-private.id
    protected = azurerm_subnet.subnet-protected.id
  }
}