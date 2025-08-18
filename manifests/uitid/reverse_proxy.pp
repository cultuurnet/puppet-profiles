class profiles::uitid::reverse_proxy (
  String $servername,
  Variant[String,Array[String]] $serveraliases = [],
  Hash $settings                               = {}

) inherits profiles {
  include profiles::apache 

}
