require 'spec_helper'

describe 'profiles::packages' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::packages'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Package <| |>' }

        it { is_expected.to contain_package('composer').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('amqp-tools').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('awscli').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('ca-certificates-publiq').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('jq').with(
          'ensure' => 'present'
          )
        }
      end
    end
  end
end
