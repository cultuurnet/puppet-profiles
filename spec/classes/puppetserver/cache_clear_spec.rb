require 'spec_helper'

describe 'profiles::puppetserver::cache_clear' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_exec('puppetserver_environment_cache_clear').with(
        'command'     => 'curl -i -k --fail -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
        'path'        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
        'refreshonly' => true,
      ) }
    end
  end
end
