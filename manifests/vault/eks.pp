# Consume the per-cluster metadata exported by Terraform into role-vault Hiera.
class profiles::vault::eks (
  Hash $clusters = {}
) inherits ::profiles {

  $configuration_directory = '/etc/vault.d/eks'

  realize Group['vault']
  realize User['vault']

  file { 'vault_eks_configuration':
    ensure  => 'directory',
    path    => $configuration_directory,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0750',
    require => [Group['vault'], User['vault']]
  }

  $clusters.each |String $cluster, Hash $configuration| {
    profiles::vault::eks_cluster { $cluster:
      *                       => $configuration,
      configuration_directory => $configuration_directory,
      require                 => File['vault_eks_configuration']
    }
  }
}
