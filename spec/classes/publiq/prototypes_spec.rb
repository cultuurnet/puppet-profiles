require 'spec_helper'

describe 'profiles::publiq::prototypes' do
  let(:hiera_config) { 'spec/support/hiera/common.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => 'http://prototypes.local'" do
        let(:params) { {
          'url'          => 'http://prototypes.local'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apache') }

        it { is_expected.to contain_class('profiles::publiq::prototypes').with(
          'url' => 'http://prototypes.local'
        ) }

        it { is_expected.to contain_class('profiles::publiq::prototypes::deployment') }

        it { is_expected.to contain_apache__vhost('prototypes.local_80').with(
          'docroot'         => '/var/www/prototypes',
          'servername'      => 'prototypes.local',
          'serveraliases'   => ['*.prototypes.local'],
          'virtual_docroot' => '/var/www/prototypes/%1',
          'docroot_owner'   => 'www-data',
          'docroot_group'   => 'www-data',
          'request_headers' => ['unset Proxy early'],
          'port'            => 80,
          'ssl'             => false
        ) }

        it { is_expected.to contain_firewall('300 accept HTTP traffic') }

        it {is_expected.to contain_class('profiles::apache').that_comes_before('Apache::Vhost[prototypes.local_80]') }
      end

      context "with url => http://prototypes.publiq.dev and deployment => false" do
        let(:params) { {
          'url'          => 'http://prototypes.publiq.dev',
          'deployment'   => false
        } }

        it { is_expected.to_not contain_class('profiles::publiq::prototypes::deployment') }

        it { is_expected.to contain_apache__vhost('prototypes.publiq.dev_80').with(
          'docroot'         => '/var/www/prototypes',
          'servername'      => 'prototypes.publiq.dev',
          'serveraliases'   => ['*.prototypes.publiq.dev'],
          'virtual_docroot' => '/var/www/prototypes/%1',
          'docroot_owner'   => 'www-data',
          'docroot_group'   => 'www-data',
          'request_headers' => ['unset Proxy early'],
          'port'            => 80,
          'ssl'             => false
        ) }

        it {is_expected.to contain_class('profiles::apache').that_comes_before('Apache::Vhost[prototypes.publiq.dev_80]') }
      end

      context "with url => https://foobar.example.com" do
        let(:params) { {
          'url' => 'https://foobar.example.com',
        } }

        context "without extra parameters" do
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate' when using HTTPS/) }
        end

        context "with certificate => 'foobar.example.com'" do
          let(:params) { super().merge( {
            'certificate' => 'foobar.example.com'
          } ) }

          it { is_expected.to contain_profiles__certificate('foobar.example.com') }

          it { is_expected.to contain_apache__vhost('foobar.example.com_443').with(
            'docroot'         => '/var/www/prototypes',
            'servername'      => 'foobar.example.com',
            'serveraliases'   => ['*.foobar.example.com'],
            'virtual_docroot' => '/var/www/prototypes/%1',
            'docroot_owner'   => 'www-data',
            'docroot_group'   => 'www-data',
            'request_headers' => ['unset Proxy early'],
            'port'            => 443,
            'ssl'             => true,
            'ssl_cert'        => '/etc/ssl/certs/foobar.example.com.bundle.crt',
            'ssl_key'         => '/etc/ssl/private/foobar.example.com.key'
          ) }

          it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

          it { is_expected.to contain_profiles__certificate('foobar.example.com').that_comes_before('Apache::Vhost[foobar.example.com_443]') }
          it { is_expected.to contain_profiles__certificate('foobar.example.com').that_notifies('Class[apache::service]') }
        end
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
      end
    end
  end
end
