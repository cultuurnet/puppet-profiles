require 'spec_helper'

describe 'profiles::glassfish::domain::service' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar-api" do
        let(:title) { 'foobar-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__glassfish__domain__service('foobar-api').with(
            'ensure' => 'present',
            'status' => 'running'
          ) }

          it { is_expected.to contain_systemd__unit_file('foobar-api.service').with(
            'path'          => '/lib/systemd/system',
            'daemon_reload' => true
          ) }

          it { is_expected.to contain_service('foobar-api').with(
            'ensure'    => 'running',
            'hasstatus' => true,
            'enable'    => true
          ) }

          it { is_expected.to contain_systemd__unit_file('foobar-api.service').that_comes_before('Service[foobar-api]') }
        end

        context 'with status => stopped' do
          let(:params) { {
            'status' => 'stopped'
          } }

          it { is_expected.to contain_service('foobar-api').with(
            'ensure'    => 'stopped',
            'hasstatus' => true,
            'enable'    => false
          ) }
        end
      end

      context "title baz-api" do
        let(:title) { 'baz-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to contain_systemd__unit_file('baz-api.service').with(
            'path'          => '/lib/systemd/system',
            'daemon_reload' => true
          ) }

          it { is_expected.to contain_service('baz-api').with(
            'ensure'    => 'running',
            'hasstatus' => true,
            'enable'    => true
          ) }

          it { is_expected.to contain_systemd__unit_file('baz-api.service').that_comes_before('Service[baz-api]') }
        end

        context 'with ensure => absent' do
          let(:params) { {
            'ensure' => 'absent'
          } }

          it { is_expected.to contain_systemd__unit_file('baz-api.service').with(
            'ensure'        => 'absent',
            'path'          => '/lib/systemd/system',
            'daemon_reload' => true
          ) }

          it { is_expected.not_to contain_service('baz-api') }
        end
      end
    end
  end
end
