resource "vault_generic_secret" "konnect_endpoints" {
  path = "kv/konnect/konnect-eu-${konnect_mesh_control_plane.mink_global_control_plane.name}/connection-details"

  data_json = jsonencode(
    merge(
      {
        cpId = konnect_mesh_control_plane.mink_global_control_plane.id
      },
      {
        for zone in var.zones :
        zone => konnect_system_account_access_token.zone_system_account_token[zone].token
      }
    )
  )
}
