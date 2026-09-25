describe 'profiles::newrelic::php::application' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'example-api' }
      let(:hiera_config) { 'spec/support/hiera/common.yaml' }
      let(:pre_condition) do
        <<~PUPPET
          realize Group['www-data']
          realize User['www-data']
        PUPPET
      end
      let(:params) do
        {
          'app_name' => 'example-api.example.com_production',
          'docroot'  => '/var/www/example-api/public'
        }
      end

      context 'without New Relic enabled' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__newrelic__php__application('example-api').with(
          'app_name' => 'example-api.example.com_production',
          'docroot'  => '/var/www/example-api/public',
          'enable'   => false
        ) }

        it { is_expected.not_to contain_class('profiles::newrelic::php') }

        it { is_expected.to contain_file('example-api newrelic php config').with(
          'ensure' => 'absent',
          'path'   => '/var/www/example-api/public/.user.ini',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }
      end

      context 'with New Relic enabled' do
        let(:params) do
          super().merge(
            'enable'                                 => true,
            'application_logging_forwarding_enabled' => true,
            'transaction_tracer_enabled'             => true,
            'distributed_tracing_enabled'            => true,
            'optional_config'                        => { 'newrelic.daemon.address' => '/run/newrelic.sock' }
          )
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::newrelic::php') }

        it { is_expected.to contain_file('example-api newrelic php config').with(
          'ensure' => 'file',
          'path'   => '/var/www/example-api/public/.user.ini',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('example-api newrelic php config').with_content(/^newrelic\.appname = "example-api\.example\.com_production"$/) }
        it { is_expected.to contain_file('example-api newrelic php config').with_content(/^newrelic\.application_logging\.forwarding\.enabled = true$/) }
        it { is_expected.to contain_file('example-api newrelic php config').with_content(/^newrelic\.transaction_tracer\.enabled = true$/) }
        it { is_expected.to contain_file('example-api newrelic php config').with_content(/^newrelic\.distributed_tracing_enabled = true$/) }
        it { is_expected.to contain_file('example-api newrelic php config').with_content(/^newrelic\.daemon\.address="\/run\/newrelic\.sock"$/) }
        it { is_expected.to contain_file('example-api newrelic php config').that_requires('Class[profiles::newrelic::php]') }
      end

      context 'with New Relic enabled and no app name override' do
        let(:title) { 'example_api' }
        let(:params) do
          {
            'docroot' => '/var/www/example-api/public',
            'enable'  => true
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('example_api newrelic php config').with_content(/^newrelic\.appname = "example-api-rp-env"$/) }
      end

      context 'with two enabled PHP applications' do
        let(:params) { super().merge('enable' => true) }
        let(:post_condition) do
          <<~PUPPET
            profiles::newrelic::php::application { 'other-api':
              app_name => 'other-api.example.com_production',
              docroot  => '/var/www/other-api/public',
              enable   => true,
            }
          PUPPET
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_profiles__newrelic__php__application_resource_count(2) }
        it { is_expected.to contain_file('example-api newrelic php config').with_path('/var/www/example-api/public/.user.ini') }
        it { is_expected.to contain_file('other-api newrelic php config').with_path('/var/www/other-api/public/.user.ini') }
      end
    end
  end
end
