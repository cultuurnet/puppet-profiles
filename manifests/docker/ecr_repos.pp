class profiles::docker::ecr_repos (
  Hash[String, String] $repos = {}
) inherits ::profiles {

  realize File['/etc/puppetlabs/facter/facts.d']

  $repos_yaml = $repos.reduce("docker_ecr_repos:\n") |$memo, $pair| {
    "${memo}  ${pair[0]}: ${pair[1]}\n"
  }

  file { 'Docker ECR external facts':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/docker_ecr_repos.yaml',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $repos_yaml,
    require => File['/etc/puppetlabs/facter/facts.d'],
  }
}
