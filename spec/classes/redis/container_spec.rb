describe 'profiles::redis::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::docker') }

        it { is_expected.to contain_service('redis-server').with(
          'ensure' => 'stopped',
          'enable' => false
        ) }

        it { is_expected.to contain_docker__run('redis').with(
          'image'            => 'redis:7-alpine',
          'net'              => 'host',
          'command'          => 'redis-server --bind 127.0.0.1',
          'health_check_cmd' => 'nc -z 127.0.0.1 6379'
        ) }

        it { is_expected.to contain_docker__run('redis').that_requires('Class[profiles::docker]') }
        it { is_expected.to contain_docker__run('redis').that_requires('Service[redis-server]') }
      end

      context 'with container_name => myapp-redis, image_tag => 7.2-alpine, maxmemory => 500mb and maxmemory_policy => allkeys-lru' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:params) { {
          'container_name'   => 'myapp-redis',
          'image_tag'        => '7.2-alpine',
          'maxmemory'        => '500mb',
          'maxmemory_policy' => 'allkeys-lru'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_docker__run('myapp-redis').with(
          'image'   => 'redis:7.2-alpine',
          'command' => 'redis-server --bind 127.0.0.1 --maxmemory 500mb --maxmemory-policy allkeys-lru'
        ) }

        it { is_expected.not_to contain_docker__run('redis') }
      end
    end
  end
end
