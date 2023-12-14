describe 'profiles::puppet::puppetserver::cache_clear' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host foo.example.com" do
        let(:node) { 'foo.example.com' }

        context "without parameters" do
          let(:params) { {} }

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.not_to contain_exec('puppetserver_environment_cache_clear') }
          end

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_exec('puppetserver_environment_cache_clear').with(
              'command'     => 'curl -i --cert /etc/puppetlabs/puppet/ssl/certs/foo.example.com.pem --key /etc/puppetlabs/puppet/ssl/private_keys/foo.example.com.pem --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --fail -X DELETE https://puppetserver.example.com:8140/puppet-admin-api/v1/environment-cache',
              'path'        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
              'refreshonly' => true,
            ) }
          end
        end
      end

      context "on host bar.example.com" do
        let(:node) { 'bar.example.com' }

        context "without parameters" do
          let(:params) { {} }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_exec('puppetserver_environment_cache_clear').with(
              'command'     => 'curl -i --cert /etc/puppetlabs/puppet/ssl/certs/bar.example.com.pem --key /etc/puppetlabs/puppet/ssl/private_keys/bar.example.com.pem --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --fail -X DELETE https://puppetserver.example.com:8140/puppet-admin-api/v1/environment-cache',
              'path'        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
              'refreshonly' => true,
            ) }
          end
        end
      end
    end
  end
end
