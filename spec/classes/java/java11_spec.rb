require 'spec_helper'

describe 'profiles::java::java11' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('publiq-tools') }

      it { is_expected.to contain_package('ca-certificates-publiq') }
      it { is_expected.to contain_package('jdk-11.0.12').with(
        'ensure' => '11.0.12-1'
      ) }

      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/java').with(
        'ensure'  => 'present',
        'altname' => 'java',
        'priority' => 10,
        'altlink'  => '/usr/bin/java'
      ) }

      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/keytool').with(
        'ensure'  => 'present',
        'altname' => 'keytool',
        'priority' => 10,
        'altlink'  => '/usr/bin/keytool'
      ) }

      it { is_expected.to contain_java_ks('publiq Development CA:/usr/lib/jvm/jdk-11.0.12/lib/security/cacerts').with(
        'certificate'  => '/usr/local/share/ca-certificates/publiq/publiq-root-ca.crt',
        'password'     => 'changeit',
        'trustcacerts' => true,
        'path'         => ['/usr/lib/jvm/jdk-11.0.12/bin', '/usr/bin']
      ) }

      it { is_expected.to contain_package('jdk-11.0.12').that_requires('Apt::Source[publiq-tools]') }
      it { is_expected.to contain_package('ca-certificates-publiq').that_requires('Apt::Source[publiq-tools]') }

      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/java').that_requires('Package[jdk-11.0.12]') }
      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/keytool').that_requires('Package[jdk-11.0.12]') }
      it { is_expected.to contain_java_ks('publiq Development CA:/usr/lib/jvm/jdk-11.0.12/lib/security/cacerts').that_requires('Package[jdk-11.0.12]') }
      it { is_expected.to contain_java_ks('publiq Development CA:/usr/lib/jvm/jdk-11.0.12/lib/security/cacerts').that_requires('Package[ca-certificates-publiq]') }
    end
  end
end
