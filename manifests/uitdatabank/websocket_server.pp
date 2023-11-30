class profiles::uitdatabank::websocket_server (
  Boolean $deployment  = true,
  Integer $listen_port = 3000
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::uitdatabank::websocket_server::deployment

    Class['profiles::nodejs'] -> Class['profiles::uitdatabank::websocket_server::deployment']
  }

  # TODO: apache + vhosts (move from hieradata here)
  # TODO: firewall rules

  # include ::profiles::uitdatabank::websocket_server::monitoring
  # include ::profiles::uitdatabank::websocket_server::metrics
  # include ::profiles::uitdatabank::websocket_server::backup
  # include ::profiles::uitdatabank::websocket_server::logging
}
