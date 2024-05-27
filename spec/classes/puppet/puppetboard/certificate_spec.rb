describe 'profiles::puppet::puppetboard::certificate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host foo.example.com" do
        let(:node) { 'foo.example.com' }

        context "with certname => foo.example.com" do
          let(:params) { {
            'certname' => 'foo.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetboard::certificate').with(
            'certname' => 'foo.example.com',
            'basedir'  => '/var/www/puppetboard'
          ) }

          it { is_expected.not_to contain_puppet_certificate('foo.example.com') }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('puppetboard basedir').with(
            'ensure' => 'directory',
            'path'   => '/var/www/puppetboard',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0700'
          ) }

          it { is_expected.to contain_file('puppetboard ssldir').with(
            'ensure' => 'directory',
            'path'   => '/var/www/puppetboard/ssl',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0700'
          ) }

          it { is_expected.to contain_file('puppetboard certificate').with(
            'ensure' => 'file',
            'path'   => '/var/www/puppetboard/ssl/public.pem',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0600',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/foo.example.com.pem'
          ) }

          it { is_expected.to contain_file('puppetboard private_key').with(
            'ensure' => 'file',
            'path'   => '/var/www/puppetboard/ssl/private.pem',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0600',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/foo.example.com.pem'
          ) }

          it { is_expected.to contain_file('puppetboard basedir').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('puppetboard basedir').that_requires('User[www-data]') }
          it { is_expected.to contain_file('puppetboard ssldir').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('puppetboard ssldir').that_requires('User[www-data]') }
          it { is_expected.to contain_file('puppetboard ssldir').that_requires('File[puppetboard basedir]') }
          it { is_expected.to contain_file('puppetboard certificate').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('puppetboard certificate').that_requires('User[www-data]') }
          it { is_expected.to contain_file('puppetboard certificate').that_requires('File[puppetboard ssldir]') }
          it { is_expected.to contain_file('puppetboard private_key').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('puppetboard private_key').that_requires('User[www-data]') }
          it { is_expected.to contain_file('puppetboard private_key').that_requires('File[puppetboard ssldir]') }
        end

        context "with certname => puppetboard.example.com and basedir => /srv/puppetboard" do
          let(:params) { {
            'certname' => 'puppetboard.example.com',
            'basedir'  => '/srv/puppetboard'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_puppet_certificate('puppetboard.example.com').with(
            'ensure'               => 'present',
            'waitforcert'          => 60,
            'renewal_grace_period' => 5,
            'clean'                => true
          ) }

          it { is_expected.to contain_file('puppetboard basedir').with(
            'path'   => '/srv/puppetboard'
          ) }

          it { is_expected.to contain_file('puppetboard ssldir').with(
            'path'   => '/srv/puppetboard/ssl'
          ) }

          it { is_expected.to contain_file('puppetboard certificate').with(
            'path'   => '/srv/puppetboard/ssl/public.pem',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/puppetboard.example.com.pem'
          ) }

          it { is_expected.to contain_file('puppetboard private_key').with(
            'path'   => '/srv/puppetboard/ssl/private.pem',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/puppetboard.example.com.pem'
          ) }

          it { is_expected.to contain_file('puppetboard certificate').that_requires('Puppet_certificate[puppetboard.example.com]') }
          it { is_expected.to contain_file('puppetboard private_key').that_requires('Puppet_certificate[puppetboard.example.com]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certname'/) }
      end
    end
  end
end
