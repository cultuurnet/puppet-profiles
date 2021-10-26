require 'spec_helper'

describe 'profiles::jenkins::controller' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with hostname => jenkins.example.com and certificate => wildcard.example.com" do
        let(:params) { {
          'hostname'    => 'jenkins.example.com',
          'certificate' => 'wildcard.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }
        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_package('jenkins').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_service('jenkins').with(
          'ensure' => 'running',
          'enable' => true
        ) }

        it { is_expected.to contain_profiles__apache__vhost__redirect('http://jenkins.example.com').with(
          'destination' => 'https://jenkins.example.com'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://jenkins.example.com').with(
          'destination'           => 'http://127.0.0.1:8080/',
          'certificate'           => 'wildcard.example.com',
          'preserve_host'         => true,
          'allow_encoded_slashes' => 'nodecode',
          'proxy_keywords'        => 'nocanon'
        ) }

        it { is_expected.to contain_package('jenkins').that_requires('User[jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_package('jenkins').that_comes_before('Package[jenkins]') }
      end

      context "with hostname => foobar.example.com and certificate => foobar.example.com" do
        let(:params) { {
          'hostname'    => 'foobar.example.com',
          'certificate' => 'foobar.example.com'
        } }

        context "with version => 1.2.3" do
          let(:params) { super().merge( { 'version' => '1.2.3' } ) }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_package('jenkins').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__redirect('http://foobar.example.com').with(
            'destination' => 'https://foobar.example.com'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://foobar.example.com').with(
            'destination'           => 'http://127.0.0.1:8080/',
            'certificate'           => 'foobar.example.com',
            'preserve_host'         => true,
            'allow_encoded_slashes' => 'nodecode',
            'proxy_keywords'        => 'nocanon'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'hostname'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate'/) }
      end
    end
  end
end
