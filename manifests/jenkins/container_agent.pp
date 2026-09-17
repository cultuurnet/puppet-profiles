class profiles::jenkins::container_agent inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['git']
  realize Package['awscli']

  realize Package['make']

  include ::profiles::jenkins::node
  include ::profiles::docker

  # Dedicated label so pipeline stages can target a container agent explicitly
  profiles::jenkins::node_labels { 'container':
    content => 'container'
  }
}
