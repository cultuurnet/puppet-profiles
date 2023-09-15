require 'spec_helper'

describe 'profiles::puppet::puppetserver::terraform' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "with bucketpath => mybucket:/mypath" do
        let(:params) { {
          'bucketpath' => 'mybucket:/mypath'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }
        it { is_expected.to contain_class('profiles::s3fs') }

        it { is_expected.to contain_file('puppetserver-terraform-data').with(
          'ensure' => 'directory',
          'path'   => '/etc/puppetlabs/code/data/terraform',
          'owner'  => 'puppet',
          'group'  => 'puppet'
        ) }

        it { is_expected.to contain_mount('puppetserver-terraform-data').with(
          'ensure'   => 'mounted',
          'name'     => '/etc/puppetlabs/code/data/terraform',
          'device'   => 'mybucket:/mypath',
          'fstype'   => 'fuse.s3fs',
          'options'  => '_netdev,nonempty,ro,nosuid,allow_other,multireq_max=5,uid=452,gid=452',
          'remounts' => false,
          'atboot'   => true
        ) }

        it { is_expected.to contain_file('puppetserver-terraform-data').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver-terraform-data').that_requires('User[puppet]') }
        it { is_expected.to contain_file('puppetserver-terraform-data').that_comes_before('Mount[puppetserver-terraform-data]') }
        it { is_expected.to contain_class('profiles::s3fs').that_comes_before('Mount[puppetserver-terraform-data]') }
      end

      context "with bucketpath => foobar:/baz" do
        let(:params) { {
          'bucketpath' => 'foobar:/baz'
        } }

        it { is_expected.to contain_mount('puppetserver-terraform-data').with(
          'ensure'   => 'mounted',
          'name'     => '/etc/puppetlabs/code/data/terraform',
          'device'   => 'foobar:/baz',
          'fstype'   => 'fuse.s3fs',
          'options'  => '_netdev,nonempty,ro,nosuid,allow_other,multireq_max=5,uid=452,gid=452',
          'remounts' => false,
          'atboot'   => true
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'bucketpath'/) }
      end
    end
  end
end
