describe 'profiles::elasticsearch' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('elasticsearch') }
        it { is_expected.to contain_user('elasticsearch') }

        it { is_expected.to contain_class('profiles::elasticsearch').with(
          'major_version' => 5,
          'version'       => nil,
          'lvm'           => false
        ) }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_apt__source('elastic-5.x') }

        it { is_expected.not_to contain_profiles__lvm__mount('elasticsearchdata') }
        it { is_expected.not_to contain_mount('/data/elasticsearch') }

        it { is_expected.to contain_sysctl('vm.max_map_count').with(
          'value' => '262144'
        ) }

        it { is_expected.to contain_class('elasticsearch').with(
          'version'           => false,
          'manage_repo'       => false,
          'api_timeout'       => 30,
          'restart_on_change' => true,
          'instances'         => {}
        ) }

        it { is_expected.to contain_class('profiles::elasticsearch::backup') }

        it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-5.x]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Sysctl[vm.max_map_count]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_class('profiles::elasticsearch::backup').that_requires('Class[elasticsearch]') }
      end

      context "with version => 8.2.1, lvm => true, volume_group => myvg and volume_size => 20G" do
        let(:params) { {
          'version'      => '8.2.1',
          'lvm'          => true,
          'volume_group' => 'myvg',
          'volume_size'  => '20G'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to contain_apt__source('elastic-8.x') }

          it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').with(
            'volume_group' => 'myvg',
            'size'         => '20G',
            'mountpoint'   => '/data/elasticsearch',
            'fs_type'      => 'ext4',
            'owner'        => 'elasticsearch',
            'group'        => 'elasticsearch'
          ) }

          it { is_expected.to contain_mount('/var/lib/elasticsearch').with(
            'ensure'  => 'mounted',
            'device'  => '/data/elasticsearch',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_class('elasticsearch').with(
            'version'           => '8.2.1',
            'manage_repo'       => false,
            'api_timeout'       => 30,
            'restart_on_change' => true,
            'instances'         => {}
          ) }

          it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').that_requires('Group[elasticsearch]') }
          it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').that_requires('User[elasticsearch]') }
          it { is_expected.to contain_mount('/var/lib/elasticsearch').that_requires('Profiles::Lvm::Mount[elasticsearchdata]') }
          it { is_expected.to contain_mount('/var/lib/elasticsearch').that_requires('Class[elasticsearch]') }
          it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-8.x]') }
        end
      end

      context "with version => 5.2.2, lvm => true, volume_group => mydatavg and volume_size => 10G" do
        let(:params) { {
          'version'      => '5.2.2',
          'lvm'          => true,
          'volume_group' => 'mydatavg',
          'volume_size'  => '10G'
        } }

        context "with volume_group mydatavg present" do
          let(:pre_condition) { 'volume_group { "mydatavg": ensure => "present" }' }

          it { is_expected.to contain_apt__source('elastic-5.x') }

          it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').with(
            'volume_group' => 'mydatavg',
            'size'         => '10G',
            'mountpoint'   => '/data/elasticsearch',
            'fs_type'      => 'ext4',
            'owner'        => 'elasticsearch',
            'group'        => 'elasticsearch'
          ) }

          it { is_expected.to contain_mount('/var/lib/elasticsearch').with(
            'ensure'  => 'mounted',
            'device'  => '/data/elasticsearch',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_class('elasticsearch').with(
            'version'           => '5.2.2',
            'manage_repo'       => false,
            'api_timeout'       => 30,
            'restart_on_change' => true,
            'instances'         => {}
          ) }

          it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-5.x]') }
        end
      end

      context "with version => 8.2.1 and major_version => 5" do
        let(:params) { {
          'version'       => '8.2.1',
          'major_version' => 5
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /incompatible combination of 'version' and 'major_version' parameters/) }
      end
    end
  end
end
