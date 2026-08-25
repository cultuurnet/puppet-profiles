describe 'profiles::elasticsearch::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without the required version parameter' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'version'/) }
      end

      context 'with version => 8.19.12, lvm => true, volume_group => datavg, volume_size => 30G and log_volume_size => 10G' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }
        let(:params) { {
          'version'         => '8.19.12',
          'lvm'             => true,
          'volume_group'    => 'datavg',
          'volume_size'     => '30G',
          'log_volume_size' => '10G'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::docker') }

        it { is_expected.to contain_service('elasticsearch').with(
          'ensure' => 'stopped',
          'enable' => false
        ) }

        it { is_expected.to contain_class('profiles::sysctl').with(
          'settings' => { 'vm.max_map_count' => { 'value' => '262144' } }
        ) }

        it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').with(
          'volume_group' => 'datavg',
          'size'         => '30G',
          'mountpoint'   => '/data/elasticsearch'
        ) }

        it { is_expected.to contain_profiles__lvm__mount('elasticsearchlogs').with(
          'volume_group' => 'datavg',
          'size'         => '10G',
          'mountpoint'   => '/data/elasticsearchlogs'
        ) }

        it { is_expected.to contain_mount('/var/lib/elasticsearch').with('device' => '/data/elasticsearch') }
        it { is_expected.to contain_mount('/var/log/elasticsearch').with('device' => '/data/elasticsearchlogs') }

        it { is_expected.to contain_docker__run('elasticsearch').with(
          'image'            => 'docker.elastic.co/elasticsearch/elasticsearch:8.19.12',
          'net'              => 'host',
          'volumes'          => ['/var/lib/elasticsearch:/usr/share/elasticsearch/data', '/var/log/elasticsearch:/usr/share/elasticsearch/logs'],
          'extra_parameters' => ['--ulimit', 'memlock=-1:-1'],
          'health_check_cmd' => 'curl -sf http://127.0.0.1:9200/_cluster/health || exit 1'
        ) }

        it { is_expected.to contain_docker__run('elasticsearch').with_env(
          ['ES_JAVA_OPTS=-Xms512m -Xmx512m', 'discovery.type=single-node', 'xpack.security.enabled=false', 'xpack.security.transport.ssl.enabled=false', 'xpack.security.http.ssl.enabled=false']
        ) }

        it { is_expected.to contain_docker__run('elasticsearch').that_requires('Service[elasticsearch]') }

        it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
          'schedule' => true,
          'lvm'      => false
        ) }

        it { is_expected.to contain_class('profiles::elasticsearch::backup').that_requires('Docker::Run[elasticsearch]') }
      end

      context 'with version => 5.6.16 (major_version < 8)' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:params) { {
          'version' => '5.6.16'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_docker__run('elasticsearch').with_env(
          ['ES_JAVA_OPTS=-Xms512m -Xmx512m', 'discovery.type=single-node']
        ) }
      end

      context 'with lvm => true but no volume_group/volume_size' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:params) { {
          'version' => '8.19.12',
          'lvm'     => true
        } }

        it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for both 'volume_group' and 'volume_size'/) }
      end
    end
  end
end
