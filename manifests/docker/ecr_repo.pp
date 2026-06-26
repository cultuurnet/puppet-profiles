class profiles::docker::ecr_repo (
  String $repo_name,
  String $region = 'eu-west-1'
) inherits ::profiles {

  realize File['/etc/puppetlabs/facter/facts.d']

  file { 'Docker ECR external facts':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/docker_ecr_repo.yaml',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "docker_ecr_repo_name: ${repo_name}\ndocker_ecr_region: ${region}\n",
    require => File['/etc/puppetlabs/facter/facts.d'],
  }
}
