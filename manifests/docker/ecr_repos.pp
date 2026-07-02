class profiles::docker::ecr_repos (
  Hash[String, Hash] $repos = {}
) inherits ::profiles {

  realize File['/etc/puppetlabs/facter/facts.d']

  file { 'Docker ECR external facts':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/docker_ecr_repos.yaml',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => stdlib::to_yaml({ 'docker_ecr_repos' => $repos }),
    require => File['/etc/puppetlabs/facter/facts.d'],
  }
}
