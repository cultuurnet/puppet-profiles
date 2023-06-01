require 'spec_helper'

describe 'profiles::puppet::puppetdb::certificate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with certname => puppetdb.example.com" do
        let(:params) { {
          'certname' => 'puppetdb.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_puppet_certificate('puppetdb.example.com').with(
          'ensure'      => 'present',
          'waitforcert' => '60'
        ) }

        it { is_expected.to contain_group('puppetdb') }
        it { is_expected.to contain_user('puppetdb') }

        it { is_expected.to contain_file('puppetdb confdir').with(
          'ensure' => 'directory',
          'path'   => '/etc/puppetlabs/puppetdb',
          'owner'  => 'puppetdb',
          'group'  => 'puppetdb',
          'mode'   => '0750'
        ) }

        it { is_expected.to contain_file('puppetdb ssldir').with(
          'ensure' => 'directory',
          'path'   => '/etc/puppetlabs/puppetdb/ssl',
          'owner'  => 'puppetdb',
          'group'  => 'puppetdb',
          'mode'   => '0700'
        ) }

        it { is_expected.to contain_file('puppetdb cacert').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
          'owner'  => 'puppetdb',
          'group'  => 'puppetdb',
          'mode'   => '0600',
          'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem'
        ) }

        it { is_expected.to contain_file('puppetdb certificate').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/puppetdb/ssl/puppetdb.example.com.pem',
          'owner'  => 'puppetdb',
          'group'  => 'puppetdb',
          'mode'   => '0600',
          'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/puppetdb.example.com.pem'
        ) }

        it { is_expected.to contain_file('puppetdb private_key').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/puppetdb/ssl/puppetdb.example.com.key',
          'owner'  => 'puppetdb',
          'group'  => 'puppetdb',
          'mode'   => '0600',
          'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/puppetdb.example.com.pem'
        ) }

        it { is_expected.to contain_file('puppetdb default certificate').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppetdb/ssl/public.pem'
        ) }

        it { is_expected.to contain_file('puppetdb default private_key').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppetdb/ssl/private.pem'
        ) }

        it { is_expected.to contain_file('puppetdb confdir').that_requires('Group[puppetdb]') }
        it { is_expected.to contain_file('puppetdb confdir').that_requires('User[puppetdb]') }
        it { is_expected.to contain_file('puppetdb ssldir').that_requires('Group[puppetdb]') }
        it { is_expected.to contain_file('puppetdb ssldir').that_requires('User[puppetdb]') }
        it { is_expected.to contain_file('puppetdb ssldir').that_requires('File[puppetdb confdir]') }
        it { is_expected.to contain_file('puppetdb cacert').that_requires('Group[puppetdb]') }
        it { is_expected.to contain_file('puppetdb cacert').that_requires('User[puppetdb]') }
        it { is_expected.to contain_file('puppetdb cacert').that_requires('File[puppetdb ssldir]') }
        it { is_expected.to contain_file('puppetdb certificate').that_requires('Group[puppetdb]') }
        it { is_expected.to contain_file('puppetdb certificate').that_requires('User[puppetdb]') }
        it { is_expected.to contain_file('puppetdb certificate').that_requires('File[puppetdb ssldir]') }
        it { is_expected.to contain_file('puppetdb certificate').that_requires('Puppet_certificate[puppetdb.example.com]') }
        it { is_expected.to contain_file('puppetdb private_key').that_requires('Group[puppetdb]') }
        it { is_expected.to contain_file('puppetdb private_key').that_requires('User[puppetdb]') }
        it { is_expected.to contain_file('puppetdb private_key').that_requires('File[puppetdb ssldir]') }
        it { is_expected.to contain_file('puppetdb private_key').that_requires('Puppet_certificate[puppetdb.example.com]') }

        it { is_expected.to contain_file('puppetdb default certificate').that_requires('File[puppetdb ssldir]') }
        it { is_expected.to contain_file('puppetdb default private_key').that_requires('File[puppetdb ssldir]') }
      end

      context "with certname => foo.example.com" do
        let(:params) { {
          'certname' => 'foo.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_puppet_certificate('foo.example.com').with(
          'ensure'      => 'present',
          'waitforcert' => '60'
        ) }

        it { is_expected.to contain_file('puppetdb certificate').with(
          'path'   => '/etc/puppetlabs/puppetdb/ssl/foo.example.com.pem',
          'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/foo.example.com.pem'
        ) }

        it { is_expected.to contain_file('puppetdb private_key').with(
          'path'   => '/etc/puppetlabs/puppetdb/ssl/foo.example.com.key',
          'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/foo.example.com.pem'
        ) }

        it { is_expected.to contain_file('puppetdb certificate').that_requires('Puppet_certificate[foo.example.com]') }
        it { is_expected.to contain_file('puppetdb private_key').that_requires('Puppet_certificate[foo.example.com]') }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certname'/) }
      end
    end
  end
end
