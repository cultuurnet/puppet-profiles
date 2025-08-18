describe 'profiles::sling' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::sling') }

      it { is_expected.to contain_apt__source('publiq-tools') }

      it { is_expected.to contain_package('sling').with(
        'ensure' => 'latest'
      ) }

      it { is_expected.to contain_file('/root/.sling').with(
        'ensure' => 'directory'
      ) }

      it { is_expected.to contain_concat('/root/.sling/env.yaml').with(
        'ensure' => 'present',
        'order'  => 'numeric'
      ) }

      it { is_expected.to contain_concat__fragment('sling_connections_header').with(
        'target'  => '/root/.sling/env.yaml',
        'content' => "connections:\n",
        'order'   => 1
      ) }

      it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[sling]') }
      it { is_expected.to contain_concat('/root/.sling/env.yaml').that_requires('File[/root/.sling]') }
    end
  end
end
