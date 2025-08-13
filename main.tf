resource "konnect_mesh_control_plane" "mink_global_control_plane" {
  provider    = konnect-beta
  name        = "mink-global-control-plane"
  description = "Global Control Plane for Mink"
  labels = {
    "terraform" = "true"
  }
}