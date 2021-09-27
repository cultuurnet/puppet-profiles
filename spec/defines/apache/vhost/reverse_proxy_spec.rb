require 'spec_helper'

describe 'profiles::apache::vhost::reverse_proxy' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  context "with title => http://leonardo.example.com" do
    let(:title) { 'http://leonardo.example.com' }

    context "with destination => http://davinci.example.com and aliases => leo.example.com" do
      let(:params) { {
        'destination' => 'http://davinci.example.com/',
        'aliases'     => 'leo.example.com'
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) { facts }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_firewall('300 accept HTTP traffic') }

          it { is_expected.to contain_apache__vhost('leonardo.example.com_80').with(
            'servername'      => 'leonardo.example.com',
            'serveraliases'   => ['leo.example.com'],
            'docroot'         => '/var/www/html',
            'manage_docroot'  => false,
            'port'            => 80,
            'ssl'             => false,
            'ssl_proxyengine' => false,
            'request_headers' => ['unset Proxy early'],
            'proxy_pass'      => {
              'path' => '/',
              'url'  => 'http://davinci.example.com/'
            }
          ) }
        end
      end
    end
  end

  context "with title => https://michelangelo.example.com" do
    let(:title) { 'https://michelangelo.example.com' }

    context "with certificate => 'foobar.example.com', destination => https://buonarotti.example.com/ and aliases => ['mich.example.com', 'angelo.example.com']" do
      let(:params) { {
        'certificate' => 'foobar.example.com',
        'destination' => 'https://buonarotti.example.com/',
        'aliases'     => ['mich.example.com', 'angelo.example.com']
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) { facts }

          it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

          it { is_expected.to contain_profiles__certificate('foobar.example.com') }

          it { is_expected.to contain_apache__vhost('michelangelo.example.com_443').with(
            'servername'      => 'michelangelo.example.com',
            'serveraliases'   => ['mich.example.com', 'angelo.example.com'],
            'port'            => 443,
            'ssl'             => true,
            'ssl_cert'        => '/etc/ssl/certs/foobar.example.com.bundle.crt',
            'ssl_key'         => '/etc/ssl/private/foobar.example.com.key',
            'ssl_proxyengine' => true,
            'proxy_pass'      => {
              'path' => '/',
              'url'  => 'https://buonarotti.example.com/'
            }
          ) }

          it { is_expected.to contain_profiles__certificate('foobar.example.com').that_comes_before('Apache::Vhost[michelangelo.example.com_443]') }
          it { is_expected.to contain_profiles__certificate('foobar.example.com').that_notifies('Class[apache::service]') }
        end
      end
    end

    context "with destination => https://buonarotti.example.com" do
      let(:params) { {
        'destination' => 'https://buonarotti.example.com'
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) { facts }

          it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for parameter certificate when using HTTPS/) }
        end
      end
    end

    context "without parameters" do
      let(:params) { {} }

      it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'destination'/) }
    end
  end

  context "with title => leonardo.example.com" do
    let(:title) { 'leonardo.example.com' }

    context "with destination => http://buonarotti.example.com" do
      let(:params) { {
        'destination' => 'http://buonarotti.example.com'
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) { facts }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects the title to be a valid HTTP URL/) }
        end
      end
    end
  end
end
