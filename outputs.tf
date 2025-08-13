# ----------------------------
# OUTPUTS
# ----------------------------

output "global_control_plane" {
  description = "ID of the Mink global control plane"
  value       = konnect_mesh_control_plane.mink_global_control_plane
}


output "zone_system_account_ids" {
  description = "System account IDs per zone"
  value = {
    for zone in var.zones :
    zone => konnect_system_account.zone_system_account[zone].id
  }
}

output "zone_system_account_names" {
  description = "System account names per zone"
  value = {
    for zone in var.zones :
    zone => konnect_system_account.zone_system_account[zone].name
  }
}

# THIS IS NOT ALLOWED, SENSITIVE DATA
# output "zone_system_account_tokens" {
#   description = "System account token names per zone"
#   value = {
#     for zone in var.zones :
#     zone => konnect_system_account_access_token.zone_system_account_token[zone].token
#   }
# }