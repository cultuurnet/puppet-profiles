describe 'profiles::users' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'User <| |>' }

        it { is_expected.to contain_user('aptly').with(
          'ensure'         => 'present',
          'gid'            => 'aptly',
          'home'           => '/home/aptly',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '450'
        ) }

        it { is_expected.to contain_user('jenkins').with(
          'ensure'         => 'present',
          'gid'            => 'jenkins',
          'groups'         => 'docker',
          'home'           => '/var/lib/jenkins',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '451'
        ) }

        it { is_expected.to contain_user('ubuntu').with(
          'ensure'         => 'present',
          'gid'            => 'ubuntu',
          'groups'         => 'docker',
          'home'           => '/home/ubuntu',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
        ) }

        it { is_expected.to contain_user('vagrant').with(
          'ensure'         => 'present',
          'gid'            => 'vagrant',
          'groups'         => 'docker',
          'home'           => '/home/vagrant',
          'managehome'     => true,
          'purge_ssh_keys' => false,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
        ) }

        it { is_expected.to contain_user('borgbackup').with(
          'ensure'         => 'present',
          'gid'            => 'borgbackup',
          'home'           => '/home/borgbackup',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1001'
        ) }

        it { is_expected.to contain_user('www-data').with(
          'ensure'         => 'present',
          'gid'            => 'www-data',
          'home'           => '/var/www',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/usr/sbin/nologin',
          'uid'            => '33'
        ) }

        it { is_expected.to contain_user('fuseki').with(
          'ensure'         => 'present',
          'gid'            => 'fuseki',
          'home'           => '/home/fuseki',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1002'
        ) }

        it { is_expected.to contain_user('puppet').with(
          'ensure'         => 'present',
          'gid'            => 'puppet',
          'home'           => '/opt/puppetlabs/server/data/puppetserver',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/usr/sbin/nologin',
          'uid'            => '452'
        ) }

        it { is_expected.to contain_user('postgres').with(
          'ensure'         => 'present',
          'gid'            => 'postgres',
          'home'           => '/var/lib/postgresql',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '453'
        ) }

        it { is_expected.to contain_user('puppetdb').with(
          'ensure'         => 'present',
          'gid'            => 'puppetdb',
          'home'           => '/opt/puppetlabs/server/data/puppetdb',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/usr/sbin/nologin',
          'uid'            => '454'
        ) }

        it { is_expected.to contain_user('redis').with(
          'ensure'         => 'present',
          'gid'            => 'redis',
          'home'           => '/var/lib/redis',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/false',
          'uid'            => '455'
        ) }

        it { is_expected.to contain_user('mysql').with(
          'ensure'         => 'present',
          'gid'            => 'mysql',
          'home'           => '/var/lib/mysql',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/false',
          'uid'            => '456'
        ) }

        it { is_expected.to contain_user('elasticsearch').with(
          'ensure'         => 'present',
          'gid'            => 'elasticsearch',
          'home'           => '/home/elasticsearch',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/false',
          'uid'            => '457'
        ) }

        it { is_expected.to contain_user('vault').with(
          'ensure'         => 'present',
          'gid'            => 'vault',
          'home'           => '/home/vault',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '458'
        ) }

        it { is_expected.to contain_user('glassfish').with(
          'ensure'         => 'present',
          'gid'            => 'glassfish',
          'home'           => '/home/glassfish',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1005'
        ) }

        it { is_expected.to contain_user('ssm-user').with(
          'ensure'         => 'present',
          'gid'            => 'ssm-user',
          'home'           => '/home/ssm-user',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/sh',
          'uid'            => '1006'
        ) }
      end
    end
  end
end
