class profiles::apache::vhost::generic (
  Hash $vhosts = undef
) {

  include ::profiles
  include ::profiles::apache
  include ::profiles::firewall::rules
  include ::profiles::certificates
  include ::apache::mod::proxy
  include ::apache::mod::rewrite
  include ::apache::mod::headers
  include ::apache::mod::http2
  include ::apache::mod::event

  realize Group['www-data']
  realize User['www-data']

  realize Firewall['300 accept HTTP traffic']

  create_resources('apache::vhost', $vhosts)
}