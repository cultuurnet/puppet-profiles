describe 'profiles::apache::vhost::redirect' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:hiera_config) { 'spec/support/hiera/common.yaml' }

      context "with title => http://leonardo.example.com" do
        let(:title) { 'http://leonardo.example.com' }

        context "with destination => https://davinci.example.com and aliases => leo.example.com" do
          let(:params) { {
            'destination' => 'https://davinci.example.com',
            'aliases'     => 'leo.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__apache__vhost__redirect('http://leonardo.example.com').with(
            'destination'       => 'https://davinci.example.com',
            'aliases'           => 'leo.example.com',
            'certificate'       => nil,
            'access_log_format' => 'extended_json'
          ) }

          it { is_expected.to contain_firewall('300 accept HTTP traffic') }

          it { is_expected.to contain_apache__vhost('leonardo.example.com_80').with(
            'servername'        => 'leonardo.example.com',
            'serveraliases'     => ['leo.example.com'],
            'docroot'           => '/var/www/html',
            'manage_docroot'    => false,
            'port'              => 80,
            'ssl'               => false,
            'request_headers'   => [
                                     'unset Proxy early',
                                     'set X-Unique-Id %{UNIQUE_ID}e'
                                   ],
            'access_log_format' => 'extended_json',
            'setenvif'          => [
                                     'X-Forwarded-Proto "https" HTTPS=on',
                                     'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                                   ],
            'redirect_source'   => '/',
            'redirect_dest'     => 'https://davinci.example.com/',
            'redirect_status'   => 'permanent'
          ) }
        end
      end

      context "with title => https://michelangelo.example.com" do
        let(:title) { 'https://michelangelo.example.com' }

        context "with certificate => 'wildcard.example.com', destination => http://buonarotti.example.com/foo/ and aliases => ['mich.example.com', 'angelo.example.com']" do
          let(:params) { {
            'certificate'       => 'wildcard.example.com',
            'destination'       => 'http://buonarotti.example.com/foo/',
            'aliases'           => ['mich.example.com', 'angelo.example.com'],
            'access_log_format' => 'combined_json'
          } }

          it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

          it { is_expected.to contain_profiles__certificate('wildcard.example.com') }

          it { is_expected.to contain_apache__vhost('michelangelo.example.com_443').with(
            'servername'        => 'michelangelo.example.com',
            'serveraliases'     => ['mich.example.com', 'angelo.example.com'],
            'port'              => 443,
            'ssl'               => true,
            'ssl_cert'          => '/etc/ssl/certs/wildcard.example.com.bundle.crt',
            'ssl_key'           => '/etc/ssl/private/wildcard.example.com.key',
            'redirect_dest'     => 'http://buonarotti.example.com/foo/',
            'access_log_format' => 'combined_json'
          ) }

          it { is_expected.to contain_profiles__certificate('wildcard.example.com').that_comes_before('Apache::Vhost[michelangelo.example.com_443]') }
          it { is_expected.to contain_profiles__certificate('wildcard.example.com').that_notifies('Class[apache::service]') }
        end

        context "with destination => http://buonarotti.example.com" do
          let(:params) { {
            'destination' => 'http://buonarotti.example.com'
          } }

          it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for parameter certificate when using HTTPS/) }
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

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects the title to be a valid HTTP URL/) }
        end
      end
    end
  end
end
