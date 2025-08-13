resource "konnect_mesh" "mesh_a" {
  provider = konnect-beta

  name     = "mesh-a"
  type     = "Mesh"
  skip_creating_initial_policies = [ "*" ]

  mtls = {
    "backends" = [
      {
        "name" = "mesh-a-ca"
        "type" = "builtin"
        "mode" = {
          str = "STRICT"
        }
      }
    ]
    mode             = "strict"
    enabled_backend   = "mesh-a-ca"
    skip_validation  = false
  }

  networking = {
    outbound = {
      passthrough = true
    }
  }

  routing = {
    default_forbid_mesh_external_service_access = false    # DONT KNOW HOW TO ALLOW PER SERVICE WHEN THIS IS TRUE
    locality_aware_load_balancing               = false
    zone_egress                                 = true
  }

  mesh_services = {
    mode = {
      str = "Exclusive" # Was working with Everywhere
    }
  }

  cp_id    = konnect_mesh_control_plane.mink_global_control_plane.id
}


resource "konnect_mesh_metric" "mesh_metric" {
  provider = konnect-beta

  name  = "mesh-a-metrics"
  mesh  = "mesh-a"
  cp_id = konnect_mesh_control_plane.mink_global_control_plane.id
  type  = "MeshMetric"

  spec = {
    target_ref = {
      kind = "Mesh"
    }

    default = {
      applications = []
      # applications = [{
      #   name = "backend"
      #   path: "/bs-metrics"
      #   port = 8000
      # }]
      
      backends = [{
        type = "OpenTelemetry"
        open_telemetry = {
          endpoint = "otel-collector-opentelemetry-collector.otel-collector:4317"
          refresh_interval = "5s"
        }
      }]
    }
  }
}

resource "konnect_mesh_traffic_permission" "allow_all" {
  provider = konnect-beta
  cp_id    = konnect_mesh_control_plane.mink_global_control_plane.id

  name      = "allow-all"
  mesh      = "mesh-a"
  type      = "MeshTrafficPermission"

  spec = {
    from = [
      {
        target_ref = {
          kind = "Mesh"
        }
        default = {
          action = "Allow"
        }
      }
    ]
  }
}


resource "konnect_mesh_access_log" "mesh_a_mesh_access_log" {
  provider = konnect-beta
  cp_id = konnect_mesh_control_plane.mink_global_control_plane.id
  
  mesh = "mesh-a"
  name = "mesh-a-access-log"
  type = "MeshAccessLog"

  spec = {
    target_ref = {
      kind = "Mesh"
    }

    from = [{
      target_ref = {
        kind = "Mesh"
      }
      default = {
        backends = [{
          type = "File"
          file = {
            path = "/tmp/access.log"
            format = {
              type = "Json"
              json = [
                { key = "start_time",                          value = "%START_TIME%" },
                { key = "kuma_mesh",                           value = "%KUMA_MESH%" },
                { key = "method",                              value = "%REQ(:METHOD)%" },
                { key = "path",                                value = "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%" },
                { key = "protocol",                            value = "%PROTOCOL%" },
                { key = "response_code",                       value = "%RESPONSE_CODE%" },
                { key = "response_flags",                      value = "%RESPONSE_FLAGS%" },
                { key = "bytes_received",                      value = "%BYTES_RECEIVED%" },
                { key = "bytes_sent",                          value = "%BYTES_SENT%" },
                { key = "duration_ms",                         value = "%DURATION%" },
                { key = "upstream_service_time",               value = "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%" },
                { key = "x_forwarded_for",                     value = "%REQ(X-FORWARDED-FOR)%" },
                { key = "user_agent",                          value = "%REQ(USER-AGENT)%" },
                { key = "request_id",                          value = "%REQ(X-REQUEST-ID)%" },
                { key = "authority",                           value = "%REQ(:AUTHORITY)%" },
                { key = "kuma_source_service",                 value = "%KUMA_SOURCE_SERVICE%" },
                { key = "kuma_destination_service",            value = "%KUMA_DESTINATION_SERVICE%" },
                { key = "kuma_source_address_without_port",    value = "%KUMA_SOURCE_ADDRESS_WITHOUT_PORT%" },
                { key = "upstream_host",                       value = "%UPSTREAM_HOST%" },
              ]
            }
          }
        }]
      }
    }]

    to = [{
      target_ref = {
        kind = "Mesh"
      }
      default = {
        backends = [{
          type = "File"
          file = {
            path = "/tmp/access.log"
            format = {
              type = "Json"
              json = [
                # repeat same JSON mapping as above
                { key = "start_time",                          value = "%START_TIME%" },
                { key = "kuma_mesh",                           value = "%KUMA_MESH%" },
                { key = "method",                              value = "%REQ(:METHOD)%" },
                { key = "path",                                value = "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%" },
                { key = "protocol",                            value = "%PROTOCOL%" },
                { key = "response_code",                       value = "%RESPONSE_CODE%" },
                { key = "response_flags",                      value = "%RESPONSE_FLAGS%" },
                { key = "bytes_received",                      value = "%BYTES_RECEIVED%" },
                { key = "bytes_sent",                          value = "%BYTES_SENT%" },
                { key = "duration_ms",                         value = "%DURATION%" },
                { key = "upstream_service_time",               value = "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%" },
                { key = "x_forwarded_for",                     value = "%REQ(X-FORWARDED-FOR)%" },
                { key = "user_agent",                          value = "%REQ(USER-AGENT)%" },
                { key = "request_id",                          value = "%REQ(X-REQUEST-ID)%" },
                { key = "authority",                           value = "%REQ(:AUTHORITY)%" },
                { key = "kuma_source_service",                 value = "%KUMA_SOURCE_SERVICE%" },
                { key = "kuma_destination_service",            value = "%KUMA_DESTINATION_SERVICE%" },
                { key = "kuma_source_address_without_port",    value = "%KUMA_SOURCE_ADDRESS_WITHOUT_PORT%" },
                { key = "upstream_host",                       value = "%UPSTREAM_HOST%" },
              ]
            }
          }
        }]
      }
    }]
  }
}

resource "konnect_mesh_trace" "mesh_trace" {
  provider = konnect-beta

  name  = "mesh-a-trace"
  mesh  = "mesh-a"
  cp_id = konnect_mesh_control_plane.mink_global_control_plane.id
  type  = "MeshTrace"

  spec = {
    target_ref = {
      kind = "Mesh"
    }

    default = {
      backends = [{
        type = "OpenTelemetry"
        open_telemetry = {
          endpoint = "otel-collector-opentelemetry-collector.otel-collector:4317"
        }
      }]
      sampling = {
        overall = {
          integer = 100
        }
        random = {
          integer = 100
        }
      }
      tags = [{
        "name" = "mesh"
        "literal" = "mesh-a"
      }]
    }
  }
}


