class profiles::ecsagent (

  String $ecs_cluster_name   = undef,
) inherits ::profiles {
  
  realize Apt::Source['publiq-tools']

  package { 'amazon-ecs-init':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }
  include profiles::docker
  file { '/etc/ecs':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => Package['amazon-ecs-init']
  }
  if $ecs_cluster_name {
    file { '/etc/ecs/ecs.config':
      ensure  => 'file',
      content => "ECS_CLUSTER=${ecs_cluster_name}",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['amazon-ecs-init']
    }
  }
  service { 'ecs':
    ensure    => 'running',
    enable    => true,
    require   => [Package['amazon-ecs-init'],Class['profiles::docker']],
    subscribe => File['/etc/ecs/ecs.config']
  }
  service { 'amazon-ecs-volume-plugin':
    ensure    => 'running',
    enable    => true,
    require   => [Package['amazon-ecs-init'],Class['profiles::docker']],
    subscribe => File['/etc/ecs/ecs.config']
  }
}
