require 'spec_helper'

describe 'profiles::base' do
  include_examples 'operating system support', 'profiles::base'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_file('data').with(
        'ensure' => 'directory',
        'group'  => 'root',
        'mode'   => '0755',
        'owner'  => 'root',
        'path'   => '/data'
        )
      }

      it { is_expected.to contain_shellvar('PATH').with(
        'ensure' => 'present',
        'target' => '/etc/environment',
        'value'  => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin'
        )
      }

      it { is_expected.to contain_shellvar('RUBYLIB').with(
        'ensure' => 'present',
        'target' => '/etc/environment',
        'value'  => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
        )
      }
    end
  end
end
