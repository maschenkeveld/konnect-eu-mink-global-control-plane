
resource "konnect_system_account" "zone_system_account" {
  for_each = toset(var.zones)

  name            = "mesh_${konnect_mesh_control_plane.mink_global_control_plane.id}_${each.key}"
  description     = "Terraform generated system account for authentication zone ${each.key} in ${konnect_mesh_control_plane.mink_global_control_plane.id} control plane."
  konnect_managed = false
}

resource "konnect_system_account_role" "zone_system_account_role" {
  for_each = toset(var.zones)

  account_id       = konnect_system_account.zone_system_account[each.key].id
  entity_id        = konnect_mesh_control_plane.mink_global_control_plane.id
  entity_region    = var.konnect_region
  entity_type_name = "Mesh Control Planes"
  role_name        = "Connector"
}

resource "time_offset" "one_year_from_now" {
  offset_years = 1
}

resource "konnect_system_account_access_token" "zone_system_account_token" {
  for_each = toset(var.zones)

  account_id = konnect_system_account.zone_system_account[each.key].id
  expires_at = time_offset.one_year_from_now.rfc3339
  name       = konnect_system_account.zone_system_account[each.key].name
}
