require 'spec_helper'

describe 'profiles::jenkins::controller' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => https://jenkins.example.com/, admin_password => passw0rd and certificate => wildcard.example.com" do
        let(:params) { {
          'url'            => 'https://jenkins.example.com/',
          'admin_password' => 'passw0rd',
          'certificate'    => 'wildcard.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller').with(
          'url'            => 'https://jenkins.example.com/',
          'admin_password' => 'passw0rd',
          'certificate'    => 'wildcard.example.com',
          'version'        => 'latest'
        ) }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }
        it { is_expected.to contain_class('profiles::java') }
        it { is_expected.to contain_class('profiles::jenkins::controller::service') }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'            => 'https://jenkins.example.com/',
          'admin_password' => 'passw0rd'
        ) }

        it { is_expected.to contain_package('jenkins').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'version'        => 'latest',
          'controller_url' => 'https://jenkins.example.com/'
        ) }

        it { is_expected.to contain_file('casc_config').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/jenkins/casc_config',
          'owner'  => 'jenkins',
          'group'  => 'jenkins'
        ) }

        it { is_expected.to contain_shellvar('JAVA_ARGS').with(
          'ensure'   => 'present',
          'variable' => 'JAVA_ARGS',
          'target'   => '/etc/default/jenkins',
          'value'    => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/casc_config'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__redirect('http://jenkins.example.com').with(
          'destination' => 'https://jenkins.example.com'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://jenkins.example.com').with(
          'destination'           => 'http://127.0.0.1:8080/',
          'certificate'           => 'wildcard.example.com',
          'preserve_host'         => true,
          'allow_encoded_slashes' => 'nodecode',
          'proxy_keywords'        => 'nocanon',
          'support_websockets'    => true
        ) }

        it { is_expected.to contain_file('casc_config').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('casc_config').that_requires('Package[jenkins]') }
        it { is_expected.to contain_file('casc_config').that_notifies('Class[profiles::jenkins::controller::service]') }
        it { is_expected.to contain_shellvar('JAVA_ARGS').that_requires('File[casc_config]') }
        it { is_expected.to contain_shellvar('JAVA_ARGS').that_notifies('Class[profiles::jenkins::controller::service]') }
        it { is_expected.to contain_package('jenkins').that_requires('User[jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_package('jenkins').that_notifies('Class[profiles::jenkins::controller::service]') }
      end

      context "with url => https://foobar.example.com/, admin_password => letmein and certificate => foobar.example.com" do
        let(:params) { {
          'url'            => 'https://foobar.example.com/',
          'admin_password' => 'letmein',
          'certificate'    => 'foobar.example.com',
          'version'        => '1.2.3'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('jenkins').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'            => 'https://foobar.example.com/',
          'admin_password' => 'letmein'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'version'        => '1.2.3',
          'controller_url' => 'https://foobar.example.com/'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__redirect('http://foobar.example.com').with(
          'destination' => 'https://foobar.example.com'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://foobar.example.com').with(
          'destination'           => 'http://127.0.0.1:8080/',
          'certificate'           => 'foobar.example.com',
          'preserve_host'         => true,
          'allow_encoded_slashes' => 'nodecode',
          'proxy_keywords'        => 'nocanon',
          'support_websockets'    => true
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate'/) }
      end
    end
  end
end
