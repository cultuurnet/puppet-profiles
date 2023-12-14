describe 'profiles::aptly::gpgkey' do
  context 'with title => foo' do
    let(:title) { 'foo' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with key_id => 1234abcd and key_source => http://example.com/keys/foo' do
          let(:params) { {
            'key_id'     => '1234abcd',
            'key_source' => 'http://example.com/keys/foo'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_group('aptly') }
          it { is_expected.to contain_user('aptly') }

          it { is_expected.to contain_gnupg_key('foo').with(
            'ensure'     => 'present',
            'key_id'     => '1234abcd',
            'user'       => 'aptly',
            'key_source' => 'http://example.com/keys/foo',
            'key_type'   => 'public'
          ) }

          it { is_expected.to contain_gnupg_key('foo').that_requires('User[aptly]') }
        end

        context 'with key_id => 000000004321dcba and key_server => keyserver.ubuntu.com' do
          let(:params) { {
            'key_id'     => '000000004321dcba',
            'key_server' => 'keyserver.ubuntu.com'
          } }

          it { is_expected.to contain_gnupg_key('foo').with(
            'ensure'     => 'present',
            'key_id'     => '000000004321dcba',
            'user'       => 'aptly',
            'key_server' => 'keyserver.ubuntu.com',
            'key_type'   => 'public'
          ) }
        end

        context 'with key_id => 3412cdab' do
          let(:params) { {
            'key_id' => '3412cdab',
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'key_source' or 'key_server'/) }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'key_id'/) }
        end
      end
    end
  end

  context 'with title => bar' do
    let(:title) { 'bar' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with key_id => 00000000aaaaaaaa11111111bbbb5678efab and key_source => https://example.com/keys/bar' do
          let(:params) { {
            'key_id'     => '00000000aaaaaaaa11111111bbbb5678efab',
            'key_source' => 'https://example.com/keys/bar'
          } }

          it { is_expected.to contain_gnupg_key('bar').with(
            'ensure'     => 'present',
            'key_id'     => '1111bbbb5678efab',
            'user'       => 'aptly',
            'key_source' => 'https://example.com/keys/bar',
            'key_type'   => 'public'
          ) }

          it { is_expected.to contain_gnupg_key('bar').that_requires('User[aptly]') }
        end

        context 'with key_id => 8765bafe and key_server => keyserver.debian.org' do
          let(:params) { {
            'key_id'     => '8765bafe',
            'key_server' => 'keyserver.debian.org'
          } }

          it { is_expected.to contain_gnupg_key('bar').with(
            'ensure'     => 'present',
            'key_id'     => '8765bafe',
            'user'       => 'aptly',
            'key_server' => 'keyserver.debian.org',
            'key_type'   => 'public'
          ) }
        end
      end
    end
  end
end
