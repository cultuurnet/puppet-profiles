describe 'profiles::docker::ecr_login' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::docker::ecr_login').with(
          'registries' => [],
          'users'      => []
        ) }

        it { is_expected.to contain_package('amazon-ecr-credential-helper').with(
          'ensure' => 'present'
        ) }
      end

      context "with registries => 'my.docker-registry.com and users => ubuntu" do
        let(:params) { {
          'registries' => 'my.docker-registry.com',
          'users'      => 'ubuntu'
        } }

        it { is_expected.to contain_group('ubuntu') }
        it { is_expected.to contain_user('ubuntu') }

        it { is_expected.to contain_package('amazon-ecr-credential-helper').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_file('ubuntu docker config directory').with(
          'ensure' => 'directory',
          'path'   => '/home/ubuntu/.docker',
          'owner'  => 'ubuntu',
          'group'  => 'ubuntu'
         ) }

        it { is_expected.to contain_file('ubuntu docker config').with(
          'ensure' => 'file',
          'path'   => '/home/ubuntu/.docker/config.json',
          'owner'  => 'ubuntu',
          'group'  => 'ubuntu'
         ) }

        it { is_expected.to contain_file('ubuntu docker config').with_content('{"credHelpers":{"my.docker-registry.com":"ecr-login"}}') }

        it { is_expected.to contain_file('ubuntu docker config directory').that_comes_before('File[ubuntu docker config]') }
        it { is_expected.to contain_file('ubuntu docker config directory').that_requires('Group[ubuntu]') }
        it { is_expected.to contain_file('ubuntu docker config directory').that_requires('User[ubuntu]') }
        it { is_expected.to contain_file('ubuntu docker config').that_requires('Group[ubuntu]') }
        it { is_expected.to contain_file('ubuntu docker config').that_requires('User[ubuntu]') }

      end

      context "with registries => [registry1.com, registry2.com] and users => [jenkins, root]" do
        let(:params) { {
          'registries' => ['registry1.com', 'registry2.com'],
          'users'      => ['jenkins', 'root']
        } }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_file('jenkins docker config directory').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/jenkins/.docker',
          'owner'  => 'jenkins',
          'group'  => 'jenkins'
         ) }

        it { is_expected.to contain_file('jenkins docker config').with(
          'ensure' => 'file',
          'path'   => '/var/lib/jenkins/.docker/config.json',
          'owner'  => 'jenkins',
          'group'  => 'jenkins'
         ) }

        it { is_expected.to contain_file('jenkins docker config').with_content('{"credHelpers":{"registry1.com":"ecr-login","registry2.com":"ecr-login"}}') }

        it { is_expected.to contain_file('root docker config directory').with(
          'ensure' => 'directory',
          'path'   => '/root/.docker',
          'owner'  => 'root',
          'group'  => 'root'
         ) }

        it { is_expected.to contain_file('root docker config').with(
          'ensure' => 'file',
          'path'   => '/root/.docker/config.json',
          'owner'  => 'root',
          'group'  => 'root'
         ) }

        it { is_expected.to contain_file('root docker config').with_content('{"credHelpers":{"registry1.com":"ecr-login","registry2.com":"ecr-login"}}') }

        it { is_expected.to contain_file('jenkins docker config directory').that_comes_before('File[jenkins docker config]') }
        it { is_expected.to contain_file('jenkins docker config directory').that_requires('Group[jenkins]') }
        it { is_expected.to contain_file('jenkins docker config directory').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('jenkins docker config').that_requires('Group[jenkins]') }
        it { is_expected.to contain_file('jenkins docker config').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('root docker config directory').that_comes_before('File[root docker config]') }
      end
    end
  end
end
