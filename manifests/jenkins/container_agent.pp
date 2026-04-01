class profiles::jenkins::container_agent inherits ::profiles {

  realize Package['git']

  include ::profiles::jenkins::node
  include ::profiles::docker
}
