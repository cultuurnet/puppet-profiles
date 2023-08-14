class profiles::apache::vhost::generic (
  Hash $vhosts = undef
) {

  include ::profiles::apache
  include ::profiles::firewall::rules
  include ::profiles::certificates
  include ::apache::mod::proxy
  include ::apache::mod::rewrite
  include ::apache::mod::headers

  realize Firewall['300 accept HTTP traffic']

  create_resources('apache::vhost', $vhosts)
}
