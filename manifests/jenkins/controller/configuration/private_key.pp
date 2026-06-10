class profiles::jenkins::controller::configuration::private_key (
  Optional[String] $key = undef
) inherits ::profiles {

  realize Group['jenkins']
  realize User['jenkins']

  file { 'Jenkins .ssh config directory':
    ensure  => 'directory',
    path    => '/var/lib/jenkins/.ssh',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0500',
    require => [Group['jenkins'], User['jenkins']]
  }

  file { 'Jenkins private key':
    ensure  => $key ? { undef => 'absent', default => 'file' },
    path    => '/var/lib/jenkins/.ssh/id_jenkins',
    content => $key,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    require => [Group['jenkins'], User['jenkins'], File['Jenkins .ssh config directory']]
  }

  if $key {
    exec { 'Jenkins public key':
      command     => '/usr/bin/ssh-keygen -y -f /var/lib/jenkins/.ssh/id_jenkins > /var/lib/jenkins/.ssh/id_jenkins.pub',
      user        => 'jenkins',
      refreshonly => true,
      subscribe   => File['Jenkins private key'],
      require     => [Group['jenkins'], User['jenkins'], File['Jenkins .ssh config directory']]
    }
  }

  if $facts['jenkins_pubkey'] {
    @@ssh_authorized_key { 'Jenkins public key':
      user => if $facts['ec2_metadata'] { 'ubuntu' } else { 'vagrant' },
      type => $facts['jenkins_pubkey']['type'],
      key  => $facts['jenkins_pubkey']['key'],
      tag  => ['jenkins']
    }
  }
}
