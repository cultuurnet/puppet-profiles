describe 'profiles::puppet::puppetdb::cli' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title root" do
        let(:title) { 'root' }

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('rubygem-puppetdb-cli') }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli('root').with(
            'server_urls'      => 'https://example.com:1234',
            'certificate_name' => nil
          ) }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
            'server_urls'      => 'https://example.com:1234',
            'certificate_name' => nil
          ) }
        end

        context "with server_urls => [https://example.com:1234, https://example.com:5678] and certificate_name => abc123" do
          let(:params) { {
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => 'abc123'
          } }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => 'abc123'
          ) }
        end

        context "without parameters" do
          let(:params) { {} }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_profiles__puppet__puppetdb__cli('root').with(
              'server_urls'      => 'http://localhost:8081',
              'certificate_name' => nil
            ) }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
          end
        end
      end

      context "with title jenkins" do
        let(:title) { 'jenkins' }

        context "with server_urls => [https://example.com:1234, https://example.com:5678] and certificate_name => abc123" do
          let(:params) { {
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => '123abc'
          } }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('jenkins').with(
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => '123abc'
          ) }
        end
      end
    end
  end
end
