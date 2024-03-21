describe 'profiles::sudo' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on AWS EC2" do
        let(:facts) do
          super().merge({ 'ec2_metadata' => true })
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('ubuntu') }
        it { is_expected.to contain_user('ubuntu') }
        it { is_expected.to contain_group('ssm-user') }
        it { is_expected.to contain_user('ssm-user') }
        it { is_expected.to_not contain_group('vagrant') }
        it { is_expected.to_not contain_user('vagrant') }

        it { is_expected.to contain_class('sudo') }

        it { is_expected.to contain_sudo__conf('ubuntu').with(
          'content'  => 'ubuntu ALL=(ALL) NOPASSWD: ALL',
          'priority' => '10'
          )
        }

        it { is_expected.to contain_sudo__conf('ssm-user').with(
          'content'  => 'ssm-user ALL=(ALL) NOPASSWD: ALL',
          'priority' => '10'
          )
        }

        it { is_expected.to contain_sudo__conf('ubuntu').that_requires('Class[sudo]') }
        it { is_expected.to contain_sudo__conf('ubuntu').that_requires('User[ubuntu]') }
        it { is_expected.to contain_sudo__conf('ssm-user').that_requires('Class[sudo]') }
        it { is_expected.to contain_sudo__conf('ssm-user').that_requires('User[ssm-user]') }
      end

      context "not on AWS EC2" do
        let(:facts) do
          super()
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to_not contain_group('ubuntu') }
        it { is_expected.to_not contain_user('ubuntu') }
        it { is_expected.to_not contain_group('ssm-user') }
        it { is_expected.to_not contain_user('ssm-user') }
        it { is_expected.to contain_group('vagrant') }
        it { is_expected.to contain_user('vagrant') }

        it { is_expected.to contain_class('sudo') }

        it { is_expected.to contain_sudo__conf('vagrant').with(
          'content'  => 'vagrant ALL=(ALL) NOPASSWD: ALL',
          'priority' => '10'
          )
        }

        it { is_expected.to contain_sudo__conf('vagrant').that_requires('Class[sudo]') }
        it { is_expected.to contain_sudo__conf('vagrant').that_requires('User[vagrant]') }
      end
    end
  end
end
