require 'spec_helper'

describe 'profiles::icinga2' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      case facts[:os]['release']['major']
      when '14.04'

        it { is_expected.to_not contain_package('icinga2-plugins-systemd-service') }
      when '16.04'

        it { is_expected.to contain_apt__source('cultuurnet-tools') }
        it { is_expected.to contain_package('icinga2-plugins-systemd-service').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('icinga2-plugins-systemd-service').that_requires('Apt::Source[cultuurnet-tools]') }
      end
    end
  end
end
