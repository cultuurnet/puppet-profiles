describe 'profiles::hosts' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node foo.example.com' do
        let(:node) { 'foo.example.com' }
        let(:trusted_facts) { {
          'certname' => 'foo.example.com',
          'hostname' => 'foo',
          'domain'   => 'example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_host('foo.example.com').with(
          'ensure'       => 'present',
          'host_aliases' => ['foo', 'localhost'],
          'ip'           => '127.0.0.1',
          'target'       => '/etc/hosts'
        ) }

        it { is_expected.to contain_host('foo').with(
          'ensure' => 'absent',
          'ip'     => '127.0.0.1',
          'target' => '/etc/hosts'
        ) }
      end

      context 'on node bar.example.com' do
        let(:node) { 'bar.example.com' }
        let(:trusted_facts) { {
          'certname' => 'bar.example.com',
          'hostname' => 'bar',
          'domain'   => 'example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_host('bar.example.com').with(
          'ensure'       => 'present',
          'host_aliases' => ['bar', 'localhost'],
          'ip'           => '127.0.0.1',
          'target'       => '/etc/hosts'
        ) }

        it { is_expected.to contain_host('bar').with(
          'ensure' => 'absent',
          'ip'     => '127.0.0.1',
          'target' => '/etc/hosts'
        ) }
      end
    end
  end
end
