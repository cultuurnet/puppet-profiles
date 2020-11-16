require 'spec_helper'

describe 'profiles::jenkins::plugin' do
  let(:title) { 'foobar' }
  let(:pre_condition) { 'package { "jenkins-cli": }' }

  context "with admin_user => john and admin_password => doe" do
    let(:params) { {
      'admin_user' => 'john',
      'admin_password' => 'doe'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_exec('jenkins plugin foobar').with(
          'command'   => "jenkins-cli -auth john:doe -webSocket install-plugin foobar -deploy",
          'path'      => [ '/usr/local/bin', '/usr/bin'],
          'unless'    => 'jenkins-cli -auth john:doe list-plugins foobar',
          'logoutput' => 'on_failure'
          )
        }

        it { is_expected.to contain_exec('jenkins plugin foobar').that_requires('Package[jenkins-cli]') }

        context "with title => guineapig, restart => true and ensure => present" do
          let(:title) { 'guineapig' }

          let(:params) {
            super().merge( {
              'restart' => true
            }
          ) }

          it { is_expected.to contain_exec('jenkins plugin guineapig').with(
            'command'   => "jenkins-cli -auth john:doe -webSocket install-plugin guineapig -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin'],
            'unless'    => 'jenkins-cli -auth john:doe list-plugins guineapig',
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to contain_exec('jenkins plugin guineapig').that_requires('Package[jenkins-cli]') }
        end
      end
    end
  end

  context "with admin_user => jane and admin_password => roe" do
    let(:params) { {
      'admin_user' => 'jane',
      'admin_password' => 'roe'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_exec('jenkins plugin foobar').with(
          'command'   => "jenkins-cli -auth jane:roe -webSocket install-plugin foobar -deploy",
          'path'      => [ '/usr/local/bin', '/usr/bin'],
          'unless'    => 'jenkins-cli -auth jane:roe list-plugins foobar',
          'logoutput' => 'on_failure'
          )
        }

        it { is_expected.to contain_exec('jenkins plugin foobar').that_requires('Package[jenkins-cli]') }

        context "with title => guineapig, restart => true and ensure => absent" do
          let(:title) { 'guineapig' }

          let(:params) {
            super().merge( {
              'ensure'  => 'absent',
              'restart' => true
            }
          ) }

          it { is_expected.to contain_exec('jenkins plugin guineapig').with(
            'command'   => "jenkins-cli -auth jane:roe -webSocket disable-plugin guineapig -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin'],
            'onlyif'    => 'jenkins-cli -auth jane:roe list-plugins guineapig',
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to contain_exec('jenkins plugin guineapig').that_requires('Package[jenkins-cli]') }
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_user'/) }
    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
  end
end
