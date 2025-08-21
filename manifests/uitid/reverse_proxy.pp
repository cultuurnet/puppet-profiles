class profiles::uitid::reverse_proxy (
  String $servername,
  Optional[String]              $certificate  = 'wildcard.uitid.be',
  Variant[String,Array[String]] $serveraliases = [],

  Hash $settings                               = {}

) inherits profiles {
  include nginx
  realize Profiles::Certificate[$certificate]
  realize Firewall['300 accept HTTPS traffic']
}
