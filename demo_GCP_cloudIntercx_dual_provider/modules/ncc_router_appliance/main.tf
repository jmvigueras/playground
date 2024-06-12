#------------------------------------------------------------------------------------------------------------
# - Create Router Appliance - VPC private
# - Create FGT BGP session to Cloud Router - VPC private
#------------------------------------------------------------------------------------------------------------
// Associate Router Applicance to FGT
resource "google_network_connectivity_spoke" "ncc_spoke" {
  name     = "${var.prefix}-fgt-ncc-spoke"
  location = var.region

  hub = var.ncc_hub_id

  linked_router_appliance_instances {
    instances {
      virtual_machine = var.fgt_self_link
      ip_address      = var.fgt_ip
    }
    site_to_site_data_transfer = false
  }
}
