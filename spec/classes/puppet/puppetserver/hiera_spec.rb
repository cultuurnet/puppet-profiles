require 'spec_helper'

describe 'profiles::puppet::puppetserver::hiera' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').with(
          'eyaml'            => false,
          'gpg_key'          => {},
          'lookup_hierarchy' => [
                                  { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                  { 'name' => 'Common data', 'path' => 'common.yaml' }
                                ]
        ) }

        it { is_expected.to contain_package('ruby_gpg').with(
          'ensure'   => 'absent',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_package('hiera-eyaml').with(
          'ensure'   => 'absent',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_package('hiera-eyaml-gpg').with(
          'ensure'   => 'absent',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_file('puppetserver eyaml configuration').with(
          'ensure' => 'absent',
          'path'   => '/opt/puppetlabs/server/data/puppetserver/.eyaml/config.yaml'
        ) }

        it { is_expected.to contain_file('puppetserver eyaml configdir').with(
          'ensure' => 'absent',
          'path'   => '/opt/puppetlabs/server/data/puppetserver/.eyaml',
          'force'  => true
        ) }

        it { is_expected.to contain_class('hiera').with(
          'hiera_version'      => '5',
          'hiera_yaml'         => '/etc/puppetlabs/code/hiera.yaml',
          'datadir_manage'     => false,
          'puppet_conf_manage' => false,
          'master_service'     => 'puppetserver',
          'hiera5_defaults'    => { 'datadir' => 'data', 'data_hash' => 'yaml_data' },
          'hierarchy'          => [
                                    { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                    { 'name' => 'Common data', 'path' => 'common.yaml' }
                                  ]
        ) }

        it { is_expected.to contain_package('hiera-eyaml-gpg').that_comes_before('Package[hiera-eyaml]') }
        it { is_expected.to contain_package('hiera-eyaml').that_comes_before('Package[ruby_gpg]') }
      end

      context "with eyaml => true and gpg_key => { 'id' => '6789DEFD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\neyaml_key\n-----END PGP PRIVATE KEY BLOCK-----' }" do
        let(:params) { {
          'eyaml'   => true,
          'gpg_key' => {
                         'id'      => '6789DEFD',
                         'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\neyaml_key\n-----END PGP PRIVATE KEY BLOCK-----"
                       }
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_package('ruby_gpg').with(
          'ensure'   => 'installed',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_package('hiera-eyaml').with(
          'ensure'   => 'installed',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_package('hiera-eyaml-gpg').with(
          'ensure'   => 'installed',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_file('puppetserver eyaml configdir').with(
          'ensure' => 'directory',
          'path'   => '/opt/puppetlabs/server/data/puppetserver/.eyaml',
          'owner'  => 'puppet',
          'group'  => 'puppet'
        ) }

        it { is_expected.to contain_file('puppetserver eyaml configuration').with(
          'ensure' => 'file',
          'path'   => '/opt/puppetlabs/server/data/puppetserver/.eyaml/config.yaml',
          'owner'  => 'puppet',
          'group'  => 'puppet',
          'source' => 'puppet:///modules/profiles/puppet/puppetserver/eyaml/config.yaml'
        ) }

        it { is_expected.to contain_class('hiera').with(
          'hiera_version'      => '5',
          'hiera_yaml'         => '/etc/puppetlabs/code/hiera.yaml',
          'datadir_manage'     => false,
          'puppet_conf_manage' => false,
          'master_service'     => 'puppetserver',
          'hiera5_defaults'    => { 'datadir' => 'data', 'data_hash' => 'yaml_data' },
          'hierarchy'          => [
                                    { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml', 'lookup_key' => 'eyaml_lookup_key', 'options' => { 'gpg_gnupghome' => '/opt/puppetlabs/server/data/puppetserver/.gnupg' } },
                                    { 'name' => 'Common data', 'path' => 'common.yaml', 'lookup_key' => 'eyaml_lookup_key', 'options' => { 'gpg_gnupghome' => '/opt/puppetlabs/server/data/puppetserver/.gnupg' } }
                                  ]
        ) }

        it { is_expected.to contain_gnupg_key('6789DEFD').with(
          'ensure'      => 'present',
          'key_id'      => '6789DEFD',
          'user'        => 'puppet',
          'key_content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\neyaml_key\n-----END PGP PRIVATE KEY BLOCK-----",
          'key_type'    => 'private'
        ) }

        it { is_expected.to contain_package('ruby_gpg').that_comes_before('Package[hiera-eyaml]') }
        it { is_expected.to contain_package('hiera-eyaml').that_comes_before('Package[hiera-eyaml-gpg]') }
        it { is_expected.to contain_file('puppetserver eyaml configdir').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver eyaml configdir').that_requires('User[puppet]') }
        it { is_expected.to contain_file('puppetserver eyaml configuration').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver eyaml configuration').that_requires('User[puppet]') }
        it { is_expected.to contain_gnupg_key('6789DEFD').that_requires('User[puppet]') }
      end

      context "with eyaml => true, gpg_key => { 'id' => '1234ABCD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----' } and lookup_hierarchy => { 'name' => 'Common data', 'path' => 'common.yaml' }" do
        let(:params) { {
          'eyaml'            => true,
          'gpg_key'          => {
                                  'id'      => '1234ABCD',
                                  'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----"
                                },
          'lookup_hierarchy' => { 'name' => 'Common data', 'path' => 'common.yaml' }
        } }

        it { is_expected.to contain_gnupg_key('1234ABCD').with(
          'ensure'      => 'present',
          'key_id'      => '1234ABCD',
          'user'        => 'puppet',
          'key_content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----",
          'key_type'    => 'private'
        ) }

        it { is_expected.to contain_gnupg_key('1234ABCD').that_requires('User[puppet]') }

        it { is_expected.to contain_class('hiera').with(
          'hiera_version'      => '5',
          'hiera_yaml'         => '/etc/puppetlabs/code/hiera.yaml',
          'datadir_manage'     => false,
          'puppet_conf_manage' => false,
          'master_service'     => 'puppetserver',
          'hiera5_defaults'    => { 'datadir' => 'data', 'data_hash' => 'yaml_data' },
          'hierarchy'          => [
                                    { 'name' => 'Common data', 'path' => 'common.yaml', 'lookup_key' => 'eyaml_lookup_key', 'options' => { 'gpg_gnupghome' => '/opt/puppetlabs/server/data/puppetserver/.gnupg' } }
                                  ]
        ) }
      end

      context "with eyaml => true and gpg_key => {}" do
        let(:params) { {
          'eyaml'   => true,
          'gpg_key' => {}
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a non-empty value for parameter 'gpg_key' when eyaml is enabled/) }
      end
    end
  end
end
