require 'spec_helper'

describe 'profiles::base' do
  include_examples 'operating system support', 'profiles::base'

  context "on Ubuntu 14.04" do
    let(:facts) { {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04'
      }
    }

    it { is_expected.to compile.with_all_deps }

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
