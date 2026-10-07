define profiles::uit::frontend::redirect_vhost (
  Stdlib::Httpurl               $redirect_url,
  Variant[Hash, Array[Hash]]    $redirect_source = [],
  Variant[String,Array[String]] $serveraliases   = []

) {

  $default_rewrites = [{
                        comment      => 'Provide environment variable REDIRECT_URL to rewrite rules',
                        rewrite_rule => "^ - [E=REDIRECT_URL:${redirect_url}]"
                      }]

  profiles::apache::vhost::basic { "http://${title}":
    rewrites      => $default_rewrites + [$redirect_source].flatten,
    serveraliases => [$serveraliases].flatten
  }
}
