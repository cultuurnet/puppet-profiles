require 'spec_helper'

describe 'profiles::jenkins::controller::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => https://jenkins.foobar.com/" do
        let(:params) { {
          'url' =>  'https://jenkins.foobar.com/'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'        => 'https://jenkins.foobar.com/'
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => {
                               'url'        => 'https://jenkins.foobar.com/'
                             }
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

      context "with url => https://builds.foobar.com/" do
        let(:params) { {
          'url'        =>  'https://builds.foobar.com/'
        } }

        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
          'configuration' => {
                               'url'        => 'https://builds.foobar.com/'
                             }
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
      end
    end
  end
end
