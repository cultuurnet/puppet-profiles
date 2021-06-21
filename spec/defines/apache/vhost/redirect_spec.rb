require 'spec_helper'

describe 'profiles::apache::vhost::redirect' do
  context "with title => leonardo.example.com" do
    let(:title) { 'leonardo.example.com' }

    context "with destination => https://davinci.example.com and aliases => leo.example.com" do
      let(:params) { {
        'destination' => 'https://davinci.example.com',
        'aliases'     => 'leo.example.com'
      } }

      on_supported_os.each do |os, facts|
          context "on #{os}" do
          let (:facts) { facts }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_firewall('300 accept HTTP traffic') }

          it { is_expected.to contain_apache__vhost('leonardo.example.com:80').with(
            'servername'      => 'leonardo.example.com',
            'serveraliases'   => ['leo.example.com'],
            'docroot'         => '/var/www/html',
            'manage_docroot'  => false,
            'port'            => 80,
            'ssl'             => false,
            'request_headers' => ['unset Proxy early'],
            'redirect_dest'   => 'https://davinci.example.com',
            'redirect_status' => 'permanent'
          ) }
        end
      end
    end
  end

  context "with title => michelangelo.example.com" do
    let(:title) { 'michelangelo.example.com' }

    context "with https => true, certificate => 'wildcard.example.com', destination => http://buonarotti.example.com and aliases => ['mich.example.com', 'angelo.example.com']" do
      let(:params) { {
        'https'       => true,
        'certificate' => 'wildcard.example.com',
        'destination' => 'http://buonarotti.example.com',
        'aliases'     => ['mich.example.com', 'angelo.example.com']
      } }

      let(:pre_condition) {
        '@profiles::certificate { "wildcard.example.com": certificate_source => "/tmp/cert/foo", key_source => "/tmp/cert/key"}'
      }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let (:facts) { facts }

          it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

          it { is_expected.to contain_profiles__certificate('wildcard.example.com') }

          it { is_expected.to contain_apache__vhost('michelangelo.example.com:443').with(
            'servername'    => 'michelangelo.example.com',
            'serveraliases' => ['mich.example.com', 'angelo.example.com'],
            'port'          => 443,
            'ssl'           => true,
            'ssl_cert'      => '/etc/ssl/certs/wildcard.example.com.bundle.crt',
            'ssl_key'       => '/etc/ssl/private/wildcard.example.com.key',
            'redirect_dest' => 'http://buonarotti.example.com'
          ) }

          it { is_expected.to contain_profiles__certificate('wildcard.example.com').that_comes_before('Apache::Vhost[michelangelo.example.com:443]') }
          it { is_expected.to contain_profiles__certificate('wildcard.example.com').that_notifies('Class[apache::service]') }
        end
      end
    end

    context "with https => true and destination => http://buonarotti.example.com" do
      let(:params) { {
        'https'       => true,
        'destination' => 'http://buonarotti.example.com'
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let (:facts) { facts }

          it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for parameter certificate when using HTTPS/) }
        end
      end
    end

    context "without parameters" do
      let(:params) { {} }

      it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'destination'/) }
    end
  end
end
