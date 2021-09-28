require 'spec_helper'

describe 'profiles::sudo' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with admin_user => ubuntu" do
        let(:params) do
          { 'admin_user' => 'ubuntu' }
        end

        it { is_expected.to contain_class('sudo') }

        it { is_expected.to contain_sudo__conf('ubuntu').with(
          'content'  => 'ubuntu ALL=(ALL) NOPASSWD: ALL',
          'priority' => '10'
          )
        }
      end

      context "with admin_user => vagrant" do
        let(:params) do
          { 'admin_user' => 'vagrant' }
        end

        it { is_expected.to contain_class('sudo') }

        it { is_expected.to contain_sudo__conf('vagrant').with(
          'content'  => 'vagrant ALL=(ALL) NOPASSWD: ALL',
          'priority' => '10'
          )
        }
      end
    end
  end
end
