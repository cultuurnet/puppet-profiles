describe 'profiles::jenkins::container_agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::jenkins::container_agent').with() }

      it { is_expected.to contain_class('profiles::jenkins::node') }
      it { is_expected.to contain_class('profiles::docker') }

      it { is_expected.to contain_package('git') }
      it { is_expected.to contain_package('awscli').that_requires('Apt::Source[publiq-tools]') }
      it { is_expected.to contain_package('make') }

      it { is_expected.to_not contain_package('build-essential') }
      it { is_expected.to_not contain_class('profiles::nodejs') }
      it { is_expected.to_not contain_class('profiles::php') }

      it { is_expected.to contain_profiles__jenkins__node_labels('container').with(
        'content' => 'container'
      ) }

      it { is_expected.to contain_concat__fragment('jenkins-swarm-client_node-labels_container').with(
        'target'  => 'jenkins-swarm-client_node-labels',
        'content' => 'container'
      ) }
    end
  end
end
