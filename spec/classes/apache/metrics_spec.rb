describe 'profiles::apache::metrics' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::collectd') }

      it { is_expected.to contain_class('apache::mod::status').with(
        'requires'    => 'ip 127.0.0.1',
        'status_path' => '/server-status'
      ) }

      it { is_expected.to contain_class('collectd::plugin::apache').with(
        'instances' => { 'localhost' => { 'url' => 'http://127.0.0.1/server-status?auto' } }
      ) }
    end
  end
end
