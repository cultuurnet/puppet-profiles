require 'spec_helper'

describe 'profiles::environment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_shellvar('system PATH').with(
        'ensure'   => 'present',
        'variable' => 'PATH',
        'target'   => '/etc/environment',
        'value'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        )
      }

      it { is_expected.to contain_shellvar('system RUBYLIB').with(
        'ensure'   => 'present',
        'variable' => 'RUBYLIB',
        'target'   => '/etc/environment',
        'value'    => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
        )
      }
    end
  end
end
