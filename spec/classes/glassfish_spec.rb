describe 'profiles::glassfish' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::glassfish').with(
          'version'         => '4.1.2.181',
          'password'        => 'adminadmin',
          'master_password' => 'changeit',
          'lvm'             => false,
          'volume_group'    => nil,
          'volume_size'     => nil
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.not_to contain_file('/opt/payara/glassfish/domains') }
        it { is_expected.not_to contain_mount('/opt/payara/glassfish/domains') }

        it { is_expected.not_to contain_profiles__lvm__mount('glassfishdata') }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_class('glassfish').with(
          'install_method'      => 'package',
          'package_prefix'      => 'payara',
          'create_service'      => false,
          'create_passfile'     => false,
          'enable_secure_admin' => false,
          'manage_java'         => false,
          'parent_dir'          => '/opt',
          'install_dir'         => 'payara',
          'version'             => '4.1.2.181'
          )
        }

        it { is_expected.to contain_class('profiles::glassfish::asadmin_passfile').with(
          'password'        => 'adminadmin',
          'master_password' => 'changeit'
        ) }

        it { is_expected.to contain_class('glassfish').that_requires('Class[profiles::java]') }
      end

      context "with version => 1.2.3, password => secret, master_password => topsecret, lvm => true, volume_group => myvg and volume_size => 10G" do
        let(:params) { {
          'version'         => '1.2.3',
          'password'        => 'secret',
          'master_password' => 'topsecret',
          'lvm'             => true,
          'volume_group'    => 'myvg',
          'volume_size'     => '10G'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to contain_file('/opt/payara').with(
            'ensure' => 'directory',
            'owner'  => 'glassfish',
            'group'  => 'glassfish'
          ) }

          it { is_expected.to contain_file('/opt/payara/glassfish').with(
            'ensure' => 'directory',
            'owner'  => 'glassfish',
            'group'  => 'glassfish'
          ) }

          it { is_expected.to contain_file('/opt/payara/glassfish/domains').with(
            'ensure' => 'directory',
            'owner'  => 'glassfish',
            'group'  => 'glassfish'
          ) }

          it { is_expected.to contain_profiles__lvm__mount('glassfishdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/glassfish',
            'fs_type'      => 'ext4',
            'owner'        => 'glassfish',
            'group'        => 'glassfish'
          ) }

          it { is_expected.to contain_mount('/opt/payara/glassfish/domains').with(
            'ensure'  => 'mounted',
            'device'  => '/data/glassfish',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_class('glassfish').with(
            'install_method'      => 'package',
            'package_prefix'      => 'payara',
            'create_service'      => false,
            'create_passfile'     => false,
            'enable_secure_admin' => false,
            'manage_java'         => false,
            'parent_dir'          => '/opt',
            'install_dir'         => 'payara',
            'version'             => '1.2.3'
            )
          }

          it { is_expected.to contain_class('profiles::glassfish::asadmin_passfile').with(
            'password'        => 'secret',
            'master_password' => 'topsecret'
          ) }

          it { is_expected.to contain_file('/opt/payara').that_requires('Group[glassfish]') }
          it { is_expected.to contain_file('/opt/payara').that_requires('User[glassfish]') }
          it { is_expected.to contain_file('/opt/payara/glassfish').that_requires('Group[glassfish]') }
          it { is_expected.to contain_file('/opt/payara/glassfish').that_requires('User[glassfish]') }
          it { is_expected.to contain_file('/opt/payara/glassfish/domains').that_requires('Group[glassfish]') }
          it { is_expected.to contain_file('/opt/payara/glassfish/domains').that_requires('User[glassfish]') }
          it { is_expected.to contain_profiles__lvm__mount('glassfishdata').that_requires('Group[glassfish]') }
          it { is_expected.to contain_profiles__lvm__mount('glassfishdata').that_requires('User[glassfish]') }
          it { is_expected.to contain_mount('/opt/payara/glassfish/domains').that_requires('Profiles::Lvm::Mount[glassfishdata]') }
          it { is_expected.to contain_mount('/opt/payara/glassfish/domains').that_requires('File[/opt/payara/glassfish/domains]') }
          it { is_expected.to contain_mount('/opt/payara/glassfish/domains').that_comes_before('Class[glassfish]') }
        end
      end

      context "with lvm => true, volume_group => datavg and volume_size => 5G" do
        let(:params) { {
          'lvm'             => true,
          'volume_group'    => 'datavg',
          'volume_size'     => '5G'
        } }

        context "with volume_group datavg present" do
          let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }

          it { is_expected.to contain_profiles__lvm__mount('glassfishdata').with(
            'volume_group' => 'datavg',
            'size'         => '5G',
            'mountpoint'   => '/data/glassfish',
            'fs_type'      => 'ext4',
            'owner'        => 'glassfish',
            'group'        => 'glassfish'
          ) }
        end
      end
    end
  end
end
