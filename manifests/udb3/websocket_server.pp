class profiles::udb3::websocket_server (
  Boolean $deployment  = true,
  Integer $listen_port = 3000
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::udb3::websocket_server::deployment

    Class['profiles::nodejs'] -> Class['profiles::udb3::websocket_server::deployment']
  }

  # TODO: apache + vhosts (move from hieradata here)
  # TODO: firewall rules

  # include ::profiles::uit::websocket_server::monitoring
  # include ::profiles::uit::websocket_server::metrics
  # include ::profiles::uit::websocket_server::backup
  # include ::profiles::uit::websocket_server::logging
}
