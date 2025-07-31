define profiles::sling::connection (
  String $type,
  Hash   $configuration = {}
) {

  include profiles
  include profiles::sling

  concat::fragment { $title:
    target  => '/root/.sling/env.yaml',
    content => template("profiles/sling/connections/${type}.erb"),
    order   => 2
  }
}
