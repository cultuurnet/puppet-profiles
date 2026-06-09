describe 'profiles::puppet::puppetserver::mfa' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with bucket => publiq-configdata:/mfa" do
        let(:params) { {
          'bucket' => 'publiq-configdata:/mfa'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::mfa').with(
          'bucket'       => 'publiq-configdata:/mfa',
          'use_iam_role' => true,
          'aws_region'   => 'eu-west-1'
        ) }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }
        it { is_expected.to contain_class('profiles::s3fs') }

        it { is_expected.to contain_file('puppetserver-mfa-data').with(
          'ensure' => 'directory',
          'path'   => '/etc/puppetlabs/code/data/mfa',
          'owner'  => 'puppet',
          'group'  => 'puppet'
        ) }

        it { is_expected.to contain_mount('puppetserver-mfa-data').with(
          'ensure'   => 'mounted',
          'name'     => '/etc/puppetlabs/code/data/mfa',
          'device'   => 'publiq-configdata:/mfa',
          'fstype'   => 'fuse.s3fs',
          'options'  => '_netdev,nonempty,ro,nosuid,allow_other,multireq_max=5,uid=452,gid=452,endpoint=eu-west-1,url=https://s3.eu-west-1.amazonaws.com,iam_role=auto',
          'remounts' => false,
          'atboot'   => true
        ) }

        it { is_expected.to contain_file('puppetserver-mfa-data').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver-mfa-data').that_requires('User[puppet]') }
        it { is_expected.to contain_file('puppetserver-mfa-data').that_comes_before('Mount[puppetserver-mfa-data]') }
        it { is_expected.to contain_class('profiles::s3fs').that_comes_before('Mount[puppetserver-mfa-data]') }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'bucket'/) }
      end
    end
  end
end
