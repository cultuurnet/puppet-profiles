describe 'profiles::qdrant' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::qdrant').with(
          'version'               => 'installed',
          'listen_address'        => '127.0.0.1',
          'service_status'        => 'running',
          'lvm'                   => false,
          'volume_group'          => nil,
          'volume_size'           => nil
        ) }

        it { is_expected.to contain_group('qdrant') }
        it { is_expected.to contain_user('qdrant') }
        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.not_to contain_firewall('400 accept qdrant traffic') }
        it { is_expected.not_to contain_profiles__lvm__mount('qdrantdata') }

        it { is_expected.to contain_file('/var/lib/qdrant').with(
          'ensure' => 'directory',
          'owner'  => 'qdrant',
          'group'  => 'qdrant'
        ) }

        it { is_expected.to contain_file('/var/lib/qdrant/storage').with(
          'ensure' => 'directory',
          'owner'  => 'qdrant',
          'group'  => 'qdrant'
        ) }

        it { is_expected.to contain_package('qdrant').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_file('qdrant config').with(
          'ensure' => 'file',
          'path'   => '/etc/qdrant/config.yaml',
          'owner'  => 'qdrant',
          'group'  => 'qdrant'
        ) }

        context 'with qdrant config YAML loaded' do
          let(:content) { YAML.load(catalogue.resource('file', 'qdrant config').send(:parameters)[:content]) }

          it { expect(content['storage']).to eq({ 'storage_path' => '/var/lib/qdrant/storage', 'snapshots_path' => '/var/lib/qdrant/snapshots' }) }
          it { expect(content['service']).to eq({ 'static_content_dir' => '/var/lib/qdrant/static', 'host' => '127.0.0.1', 'http_port' => 6333 }) }
        end

        it { is_expected.to contain_service('qdrant').with(
          'enable' => true,
          'ensure' => 'running'
        ) }

        it { is_expected.to contain_group('qdrant').that_comes_before('File[/var/lib/qdrant]') }
        it { is_expected.to contain_user('qdrant').that_comes_before('File[/var/lib/qdrant]') }
        it { is_expected.to contain_group('qdrant').that_comes_before('Package[qdrant]') }
        it { is_expected.to contain_user('qdrant').that_comes_before('Package[qdrant]') }
        it { is_expected.to contain_file('/var/lib/qdrant/storage').that_comes_before('Package[qdrant]') }
        it { is_expected.to contain_file('qdrant config').that_requires('Package[qdrant]') }
        it { is_expected.to contain_file('qdrant config').that_notifies('Service[qdrant]') }
        it { is_expected.to contain_package('qdrant').that_notifies('Service[qdrant]') }
      end

      context 'with version => 1.2.3, listen_address => 0.0.0.0, lvm => true, volume_group => datavg and volume_size => 20G' do
        let(:params) { {
          'version'        => '1.2.3',
          'listen_address' => '0.0.0.0',
          'lvm'            => true,
          'volume_group'   => 'datavg',
          'volume_size'    => '20G'
        } }

        context 'with volume_group datavg present' do
          let(:pre_condition) { ['volume_group { "datavg": ensure => "present" }'] }

          it { is_expected.to contain_firewall('400 accept qdrant traffic') }

          it { is_expected.to contain_profiles__lvm__mount('qdrantdata').with(
            'volume_group' => 'datavg',
            'size'         => '20G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/qdrant',
            'owner'        => 'qdrant',
            'group'        => 'qdrant'
          ) }

          it { is_expected.to contain_mount('/var/lib/qdrant/storage').with(
            'ensure'  => 'mounted',
            'device'  => '/data/qdrant',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_package('qdrant').with(
            'ensure' => '1.2.3'
          ) }

          context 'with qdrant config YAML loaded' do
            let(:content) { YAML.load(catalogue.resource('file', 'qdrant config').send(:parameters)[:content]) }

            it { expect(content['service']).to eq({ 'static_content_dir' => '/var/lib/qdrant/static', 'host' => '0.0.0.0', 'http_port' => 6333 }) }
          end

          it { is_expected.to contain_group('qdrant').that_comes_before('Profiles::Lvm::Mount[qdrantdata]') }
          it { is_expected.to contain_user('qdrant').that_comes_before('Profiles::Lvm::Mount[qdrantdata]') }
          it { is_expected.to contain_profiles__lvm__mount('qdrantdata').that_comes_before('Mount[/var/lib/qdrant/storage]') }
          it { is_expected.to contain_mount('/var/lib/qdrant/storage').that_requires('Profiles::Lvm::Mount[qdrantdata]') }
          it { is_expected.to contain_mount('/var/lib/qdrant/storage').that_requires('File[/var/lib/qdrant/storage]') }
          it { is_expected.to contain_mount('/var/lib/qdrant/storage').that_comes_before('Package[qdrant]') }
        end
      end

      context 'with lvm => true, volume_group => myvg, service_status => stopped and volume_size => 10G' do
        let(:params) { {
          'service_status'        => 'stopped',
          'lvm'                   => true,
          'volume_group'          => 'myvg',
          'volume_size'           => '10G'
        } }

        context 'with volume_groups myvg' do
          let(:pre_condition) { ['volume_group { "myvg": ensure => "present" }'] }

          it { is_expected.to contain_profiles__lvm__mount('qdrantdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/qdrant',
            'owner'        => 'qdrant',
            'group'        => 'qdrant'
          ) }

          it { is_expected.to contain_service('qdrant').with(
            'enable' => false,
            'ensure' => 'stopped'
          ) }
        end
      end

      context 'with lvm => true, volume_group => datavg' do
        let(:params) { {
          'lvm'          => true,
          'volume_group' => 'myvg'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end

      context 'with lvm => true, volume_size => 100G' do
        let(:params) { {
          'lvm'         => true,
          'volume_size' => '100G'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end
    end
  end
end
