require 'spec_helper'

describe 'profiles::jenkins::controller::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
        'ensure'        => 'present',
        'restart'       => false,
        'configuration' => nil
      ) }

      it { is_expected.to contain_profiles__jenkins__plugin('swarm').with(
        'ensure'        => 'present',
        'restart'       => false,
        'configuration' => nil
      ) }

      it { is_expected.to contain_exec('jenkins configuration-as-code reload').with(
        'command'     => 'jenkins-cli reload-jcasc-configuration',
        'user'        => 'jenkins',
        'refreshonly' => true,
        'logoutput'   => 'on_failure',
        'path'        => [ '/usr/local/bin', '/usr/bin', '/bin']
      ) }

      it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').that_comes_before('Exec[jenkins configuration-as-code reload]') }
    end
  end
end
