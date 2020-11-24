require 'spec_helper'

describe 'profiles::jenkins::plugin' do
  let(:title) { 'foobar' }

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::cli') }

        it { is_expected.to contain_exec('jenkins plugin foobar').with(
          'command'   => "jenkins-cli install-plugin foobar -deploy",
          'path'      => [ '/usr/local/bin', '/usr/bin'],
          'unless'    => 'jenkins-cli list-plugins foobar',
          'logoutput' => 'on_failure'
          )
        }

        it { is_expected.to contain_exec('jenkins plugin foobar').that_requires('Class[profiles::jenkins::cli]') }

        context "with title => guineapig, restart => true and ensure => present" do
          let(:title) { 'guineapig' }

          let(:params) {
            super().merge({
              'restart' => true
            })
          }

          it { is_expected.to contain_exec('jenkins plugin guineapig').with(
            'command'   => "jenkins-cli install-plugin guineapig -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin'],
            'unless'    => 'jenkins-cli list-plugins guineapig',
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to contain_exec('jenkins plugin guineapig').that_requires('Class[profiles::jenkins::cli]') }
        end

        context "with title => guineapig, restart => true and ensure => absent" do
          let(:title) { 'hedgehog' }

          let(:params) {
            super().merge({
              'ensure'  => 'absent',
              'restart' => true
            })
          }

          it { is_expected.to contain_exec('jenkins plugin hedgehog').with(
            'command'   => "jenkins-cli disable-plugin hedgehog -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin'],
            'onlyif'    => 'jenkins-cli list-plugins hedgehog',
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to contain_exec('jenkins plugin hedgehog').that_requires('Class[profiles::jenkins::cli]') }
        end
      end
    end
  end
end
