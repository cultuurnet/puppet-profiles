describe 'profiles::jenkins::node' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'on node jenkins1.example.com' do
          let(:node) { 'jenkins1.example.com' }

          context "with user => john, password => doe and url => 'https://jenkins.example.com/'" do
            let(:params) { {
              'user'           => 'john',
              'password'       => 'doe',
              'controller_url' => 'https://jenkins.example.com/'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::jenkins::node').with(
              'user'           => 'john',
              'password'       => 'doe',
              'version'        => 'latest',
              'controller_url' => 'https://jenkins.example.com/',
              'bootstrap'      => false,
              'lvm'            => false,
              'volume_group'   => nil,
              'volume_size'    => nil,
              'executors'      => 1,
              'labels'         => []
            ) }

            it { is_expected.to contain_apt__source('publiq-jenkins') }
            it { is_expected.to contain_apt__source('publiq-jenkins') }
            it { is_expected.to contain_class('profiles::java') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::bootstrap') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::homebuilt') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::playwright') }
            it { is_expected.to contain_group('jenkins') }
            it { is_expected.to contain_user('jenkins') }

            it { is_expected.to contain_package('jenkins-swarm-client').with(
              'ensure' => 'latest'
            ) }

            it { is_expected.to contain_profiles__puppet__puppetdb__cli('jenkins') }

            it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('jenkins1.example.com').with(
              'policies' => ['jenkins_certificate']
            ) }

            it { is_expected.not_to contain_profiles__lvm__mount('jenkinsdata') }
            it { is_expected.not_to contain_mount('/var/lib/jenkins-swarm-client') }

            it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').with(
              'ensure'  => 'directory',
              'owner'   => 'jenkins',
              'group'   => 'jenkins',
              'mode'    => '0755'
            ) }

            it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').with(
              'ensure'  => 'file',
              'owner'   => 'jenkins',
              'group'   => 'jenkins',
              'path'    => '/etc/jenkins-swarm-client/password',
              'mode'    => '0600',
              'content' => "doe"
            ) }

            it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
              'ensure'  => 'file',
              'owner'   => 'jenkins',
              'group'   => 'jenkins',
              'path'    => '/etc/jenkins-swarm-client/node-labels.conf',
              'mode'    => '0644'
            ) }

            case facts[:os]['release']['major']
            when '14.04'
              it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                'content' => "ubuntu\n14.04\ntrusty"
              ) }
            when '16.04'
              it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                'content' => "ubuntu\n16.04\nxenial"
              ) }
            end

            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with(
              'ensure'  => 'file',
              'path'    => '/etc/default/jenkins-swarm-client',
              'mode'    => '0644'
            ) }

            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^JENKINS_USER=john$/) }
            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^CONTROLLER_URL=https:\/\/jenkins\.example\.com\/$/) }
            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^BUILD_EXECUTORS=1$/) }

            it { is_expected.to contain_service('jenkins-swarm-client').with(
              'ensure' => 'running',
              'enable' => true
            ) }

            it { is_expected.to contain_package('jenkins-swarm-client').that_requires('Apt::Source[publiq-jenkins]') }
            it { is_expected.to contain_package('jenkins-swarm-client').that_notifies('Service[jenkins-swarm-client]') }
            it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').that_requires('User[jenkins]') }
            it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').that_requires('Group[jenkins]') }
            it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').that_notifies('Service[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('User[jenkins]') }
            it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('Group[jenkins]') }
            it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('Package[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_notifies('Service[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('User[jenkins]') }
            it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('Group[jenkins]') }
            it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('Package[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_notifies('Service[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').that_requires('Package[jenkins-swarm-client]') }
            it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').that_notifies('Service[jenkins-swarm-client]') }
            it { is_expected.to contain_service('jenkins-swarm-client').that_requires('User[jenkins]') }
            it { is_expected.to contain_service('jenkins-swarm-client').that_requires('Group[jenkins]') }
            it { is_expected.to contain_service('jenkins-swarm-client').that_subscribes_to('Class[profiles::java]') }
          end

          context "with user => jane, password => roe, controller_url => 'http://localhost:5555/', bootstrap => true, lvm => true, volume_group => myvg, volume_size => 7G and executors => 4" do
            let(:params) { {
              'user'           => 'jane',
              'password'       => 'roe',
              'controller_url' => 'http://localhost:5555/',
              'bootstrap'      => true,
              'lvm'            => true,
              'volume_group'   => 'myvg',
              'volume_size'    => '7G',
              'executors'      => 4
            } }

            context "with volume_group myvg present" do
              let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

              it { is_expected.to contain_class('profiles::jenkins::buildtools::bootstrap') }
              it { is_expected.not_to contain_class('profiles::jenkins::buildtools::homebuilt') }
              it { is_expected.not_to contain_class('profiles::jenkins::buildtools::playwright') }

              it { is_expected.to contain_profiles__lvm__mount('jenkinsdata').with(
                'volume_group' => 'myvg',
                'size'         => '7G',
                'mountpoint'   => '/data/jenkins',
                'fs_type'      => 'ext4',
                'owner'        => 'jenkins',
                'group'        => 'jenkins'
              ) }

              it { is_expected.to contain_mount('/var/lib/jenkins-swarm-client').with(
                'ensure'  => 'mounted',
                'device'  => '/data/jenkins',
                'fstype'  => 'none',
                'options' => 'rw,bind'
              ) }

              it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').with(
                'ensure'  => 'directory',
                'owner'   => 'jenkins',
                'group'   => 'jenkins',
                'mode'    => '0755'
              ) }

              it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').with(
                'content' => 'roe'
              ) }

              it { is_expected.to contain_profiles__lvm__mount('jenkinsdata').that_requires('Group[jenkins]') }
              it { is_expected.to contain_profiles__lvm__mount('jenkinsdata').that_requires('User[jenkins]') }
              it { is_expected.to contain_mount('/var/lib/jenkins-swarm-client').that_requires('Profiles::Lvm::Mount[jenkinsdata]') }
              it { is_expected.to contain_mount('/var/lib/jenkins-swarm-client').that_requires('File[/var/lib/jenkins-swarm-client]') }
              it { is_expected.to contain_mount('/var/lib/jenkins-swarm-client').that_comes_before('Package[jenkins-swarm-client]') }
              it { is_expected.to contain_mount('/var/lib/jenkins-swarm-client').that_notifies('Service[jenkins-swarm-client]') }
              it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').that_comes_before('Package[jenkins-swarm-client]') }
              it { is_expected.to contain_file('/var/lib/jenkins-swarm-client').that_notifies('Service[jenkins-swarm-client]') }
              it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^JENKINS_USER=jane$/) }
              it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^CONTROLLER_URL=http:\/\/localhost:5555\/$/) }
              it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^BUILD_EXECUTORS=4$/) }

              context "with labels => foo" do
                let(:params) {
                  super().merge({
                    'labels' => 'foo'
                  })
                }

                case facts[:os]['release']['major']
                when '14.04'
                  it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                    'content' => "ubuntu\n14.04\ntrusty\nfoo"
                  ) }
                when '16.04'
                  it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                    'content' => "ubuntu\n16.04\nxenial\nfoo"
                  ) }
                end
              end
            end

            context "with labels => [bar, baz, oomph]" do
              let(:params) {
                super().merge({
                  'labels' => ['bar', 'BAZ', 'oomph']
                })
              }

              case facts[:os]['release']['major']
              when '14.04'
                it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                  'content' => "ubuntu\n14.04\ntrusty\nbar\nbaz\noomph"
                ) }
              when '16.04'
                it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
                  'content' => "ubuntu\n16.04\nxenial\nbar\nbaz\noomph"
                ) }
              end
            end
          end

          context "without parameters it uses hieradata from profiles::jenkins::controller" do
            let(:params) { {} }

            it { is_expected.to contain_class('profiles::jenkins::node').with(
              'user'           => 'admin',
              'password'       => 'bar',
              'version'        => 'latest',
              'controller_url' => 'https://foobar.com/',
              'lvm'            => false,
              'volume_group'   => nil,
              'volume_size'    => nil,
              'executors'      => 1,
              'labels'         => []
            ) }
          end
        end

        context 'on node jenkins2.example.com' do
          let(:node) { 'jenkins2.example.com' }

          context 'without parameters' do
            let(:params) { {} }

            it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('jenkins2.example.com').with(
              'policies' => ['jenkins_certificate']
            ) }
          end
        end
      end
    end
  end
end
