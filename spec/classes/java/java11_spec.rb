require 'spec_helper'

describe 'profiles::java::java11' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

      it { is_expected.to contain_package('jdk-11.0.12').with(
        'ensure' => '11.0.12-1'
      ) }

      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/java').with(
        'ensure'  => 'present',
        'altname' => 'java',
        'priority' => 10,
        'altlink'  => '/usr/bin/java'
      ) }

      it { is_expected.to contain_package('jdk-11.0.12').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

      it { is_expected.to contain_alternative_entry('/usr/lib/jvm/jdk-11.0.12/bin/java').that_requires('Package[jdk-11.0.12]') }
    end
  end
end
