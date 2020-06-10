require 'spec_helper'

describe 'profiles::sysctl' do
  include_examples 'operating system support', 'profiles::sysctl'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_package('augeas-tools').with(
        'ensure' => 'present'
        )
      }

      it { is_expected.to contain_package('ruby-augeas').with(
        'ensure' => 'present'
        )
      }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to have_sysctl_resource_count(0) }
      end

      context "with settings => { 'vm.overcommit_memory' => { 'value' => '1'}, 'vm.max_map_count => { 'value' => '262144', 'persist' => false } }" do
        let (:params) {
          {
            'settings' => {
              'vm.overcommit_memory' => { 'value' => '1' },
              'vm.max_map_count' => { 'value' => '262144', 'persist' => false }
            }
          }
        }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_sysctl('vm.overcommit_memory').with(
          'value' => '1'
          )
        }

        it { is_expected.to contain_sysctl('vm.max_map_count').with(
          'value'   => '262144',
          'persist' => false
          )
        }

        it { is_expected.to contain_sysctl('vm.overcommit_memory').that_requires('Package[augeas-tools]') }
        it { is_expected.to contain_sysctl('vm.overcommit_memory').that_requires('Package[ruby-augeas]') }

        it { is_expected.to contain_sysctl('vm.max_map_count').that_requires('Package[augeas-tools]') }
        it { is_expected.to contain_sysctl('vm.max_map_count').that_requires('Package[ruby-augeas]') }
      end
    end
  end
end
