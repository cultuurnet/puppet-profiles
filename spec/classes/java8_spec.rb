require 'spec_helper'

describe 'profiles::java8' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

      it { is_expected.to contain_package('oracle-jdk8-archive').with(
        'ensure' => '8u151'
        )
      }

      it { is_expected.to contain_package('oracle-jdk8-archive').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

      it { is_expected.to contain_file('oracle-java8-installer.preseed').with(
        'path'   => '/var/tmp/oracle-java8-installer.preseed',
        'source' => 'puppet:///modules/profiles/java8/oracle-java8-installer.preseed',
        'mode'   => '0600',
        'backup' => false,
      ) }

      it { is_expected.to contain_package('oracle-java8-installer').with(
        'ensure'       => '8u151-1~webupd8~0',
        'responsefile' => '/var/tmp/oracle-java8-installer.preseed'
        )
      }

      it { is_expected.to contain_package('oracle-java8-installer').that_requires('File[oracle-java8-installer.preseed]') }
      it { is_expected.to contain_package('oracle-java8-installer').that_requires('Package[oracle-jdk8-archive]') }

      it { is_expected.to contain_shellvar('JAVA_HOME').with(
        'ensure' => 'present',
        'target' => '/etc/environment',
        'value'  => '/usr/lib/jvm/java-8-oracle'
      ) }
    end
  end
end
