describe 'profiles::puppet::puppetserver::vault' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node foo.example.com' do
        let(:node) { 'foo.example.com' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('vault-puppetserver-gem').with(
          'ensure'   => 'installed',
          'name'     => 'vault',
          'provider' => 'puppetserver_gem'
        ) }

        it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('foo.example.com') }
      end
    end
  end
end
