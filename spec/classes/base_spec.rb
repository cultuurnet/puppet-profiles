require 'spec_helper'

describe 'profiles::base' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('lvm').with(
        'manage_pkg' => true
        )
      }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_package('ca-certificates-publiq') }

      it { is_expected.to contain_package('policykit-1').with(
        'ensure' => 'latest'
      ) }

      it { is_expected.to contain_package('snapd').with(
        'ensure' => 'latest'
      ) }

      it { is_expected.to contain_class('lvm').with(
        'manage_pkg' => true
        )
      }

      it { is_expected.to contain_file('data').with(
        'ensure' => 'directory',
        'group'  => 'root',
        'mode'   => '0755',
        'owner'  => 'root',
        'path'   => '/data'
        )
      }

      it { is_expected.to contain_shellvar('system PATH').with(
        'ensure'   => 'present',
        'variable' => 'PATH',
        'target'   => '/etc/environment',
        'value'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        )
      }

      it { is_expected.to contain_shellvar('system RUBYLIB').with(
        'ensure'   => 'present',
        'variable' => 'RUBYLIB',
        'target'   => '/etc/environment',
        'value'    => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
        )
      }

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
