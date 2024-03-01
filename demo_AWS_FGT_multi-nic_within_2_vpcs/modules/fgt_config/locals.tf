locals {
  # fgt_id
  fgt_id = var.config_spoke ? "${var.spoke["id"]}-${replace(var.fgt_id, ".", "")}" : var.config_hub ? "${var.hub[0]["id"]}-${replace(var.fgt_id, ".", "")}" : replace(var.fgt_id, ".", "")
  # Map of interfaces config
  ports_config = var.ports_config
  # First public interface (necessary to configure for FortiFlex licensing)
  port1_config = one([for i, v in local.ports_config : v if v["port"] == "port1"])
  # Port mapping
  map_type_port = { for i, v in local.ports_config : v["tag"] => v["port"] }
  # IP to port map
  map_type_ip = { for i, v in local.ports_config : v["tag"] => v["ip"] }
  # IP to port map
  map_type_gw = { for i, v in local.ports_config : v["tag"] => v["gw"] }
  # Default private port name
  default_private_port = var.default_private_port

  # -----------------------------------------------------------------------------------------------------
  # HA locals
  # -----------------------------------------------------------------------------------------------------
  # HA member ID
  # - az(2).fgt(1) -> 1 x 2
  ha_member_id = trimprefix(one(slice(split(".", var.fgt_id), 1, 2)), var.fgt_id_prefix) * trimprefix(one(slice(split(".", var.fgt_id), 0, 1)), "az")
  # HA peer ips
  ha_peer_ips = [
    for k, v in var.ha_members :
    {
      "${local.fgcp_port_name}" = one([for port in v : lookup(port, "ip", "") if port["tag"] == local.fgcp_port_name])
      "${local.fgsp_port_name}" = one([for port in v : lookup(port, "ip", "") if port["tag"] == local.fgsp_port_name])
    } if k != var.fgt_id
  ]
  # -----------------------------------------------------------------------------------------------------
  # FGCP cluster protocol
  # -----------------------------------------------------------------------------------------------------
  # FGCP port name
  fgcp_port_name = var.fgcp_port
  # FGCP priority
  fgcp_priority = 210 - local.ha_member_id * 10
  # FGCP port 
  fgcp_port = lookup(local.map_type_port, local.fgcp_port_name, "")
  # FGCP IP
  fgcp_ip = lookup(local.map_type_ip, local.fgcp_port_name, "")
  # FGCP gateway
  fgcp_gw = lookup(local.map_type_gw, local.fgcp_port_name, "")
  # FGCP peer ip
  fgcp_peer_ip = length(local.ha_peer_ips) >= 1 ? element(local.ha_peer_ips, 0)[local.fgcp_port_name] : null
  # -----------------------------------------------------------------------------------------------------
  # FGSP cluster protocol
  # -----------------------------------------------------------------------------------------------------
  # FGSP port name
  fgsp_port_name = var.fgsp_port
  # List of FGSP peers
  fgsp_peer_ips = [for ip in local.ha_peer_ips : ip[local.fgsp_port_name]]
  # FGSP master IP (auto-scale)
  # - If this member is the master value is null
  fgsp_master_ip = one(compact([
    for v in var.ha_members[var.ha_master_id] :
    v["ip"] if v["tag"] == local.fgsp_port_name && v["ip"] != local.map_type_ip[local.fgsp_port_name]
    ]
  ))
  # -----------------------------------------------------------------------------------------------------
  # VXLAN peers BGP
  # -----------------------------------------------------------------------------------------------------
  vxlan_peers_bgp = length(var.vxlan_peers) > 0 ? flatten([
    for i, v in var.vxlan_peers : [
      for ip in split(",", lookup(v,"remote_ip","")) :
      { bgp_asn       = lookup(v,"bgp_asn", "")
        remote_ip     = trimspace(ip)
        route_map_in  = lookup(v, "route_map_in", "")
        route_map_out = lookup(v, "route_map_out", "")
      }
    ]
    ]
  ) : []

}