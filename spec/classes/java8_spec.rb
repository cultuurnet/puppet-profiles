require 'spec_helper'

describe 'profiles::java8' do
  include_examples 'operating system support', 'profiles::java8'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_package('oracle-jdk8-archive').with(
        'ensure' => '8u151'
        )
      }

      it { is_expected.to contain_package('oracle-jdk8-archive').that_requires('Apt::Source[cultuurnet-tools]') }

      it { is_expected.to contain_class('java8').with(
        'installer_version' => '8u151-1~webupd8~0',
        'manage_repos'      => false
        )
      }

      it { is_expected.to contain_class('java8').that_requires('Package[oracle-jdk8-archive]') }
    end
  end
end
