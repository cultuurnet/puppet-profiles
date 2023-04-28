require 'spec_helper'

describe 'profiles::base' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "on AWS EC2" do
        let(:facts) do
          super().merge({ 'ec2_metadata' => 'true' })
        end

        it { is_expected.to contain_package('awscli') }
        it { is_expected.to contain_group('ubuntu') }
        it { is_expected.to contain_user('ubuntu') }
        it { is_expected.to_not contain_group('vagrant') }
        it { is_expected.to_not contain_user('vagrant') }
        it { is_expected.to contain_class('profiles::sudo').with(
          'admin_user' => 'ubuntu'
          )
        }
      end

      context "not on AWS EC2" do
        let(:facts) do
          super()
        end

        it { is_expected.to_not contain_package('awscli') }
        it { is_expected.to_not contain_group('ubuntu') }
        it { is_expected.to_not contain_user('ubuntu') }
        it { is_expected.to contain_group('vagrant') }
        it { is_expected.to contain_user('vagrant') }
        it { is_expected.to contain_class('profiles::sudo').with(
          'admin_user' => 'vagrant'
          )
        }
      end
    end
  end
end
