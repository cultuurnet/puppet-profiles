describe 'profiles::vault' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with gpg_keys => { abcd1234 => { tag => foo, key => -----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUB     LIC KEY BLOCK----- }, cdef3456 => { tag => bar, key => -----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK----- } }' do
        let(:params) { {
          'gpg_keys' => {
                          'abcd1234' => { 'tag' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                          'cdef3456' => { 'tag' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                        }
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault').with(
          'version'         => 'latest',
          'auto_unseal'     => false,
          'service_status'  => 'running',
          'service_address' => '127.0.0.1',
          'gpg_keys'        => {
                                 'abcd1234' => { 'tag' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                                 'cdef3456' => { 'tag' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                               }
        ) }

        it { is_expected.not_to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '127.0.0.1'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        context 'without fact vault_initialized' do
          it { is_expected.to contain_class('profiles::vault::init').with(
            'gpg_keys' => {
                            'abcd1234' => { 'tag' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                            'cdef3456' => { 'tag' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                          }
          ) }

          it { is_expected.to contain_class('profiles::vault::init').that_requires('Class[profiles::vault::service]') }
          it { is_expected.to contain_class('profiles::vault::init').that_comes_before('Class[profiles::vault::seal]') }
        end

        context 'with fact vault_initialized' do
          let(:facts) { facts.merge({ 'vault_initialized' => true }) }

          it { is_expected.not_to contain_class('profiles::vault::init') }
        end

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'auto_unseal' => false
        ) }

        it { is_expected.to contain_class('profiles::vault::install').that_comes_before('Class[profiles::vault::configuration]') }
        it { is_expected.to contain_class('profiles::vault::install').that_notifies('Class[profiles::vault::service]') }
        it { is_expected.to contain_class('profiles::vault::configuration').that_notifies('Class[profiles::vault::service]') }
        it { is_expected.to contain_class('profiles::vault::seal').that_requires('Class[profiles::vault::service]') }
      end

      context 'with version => 1.2.3, auto_unseal => true, service_status => stopped and service_address => 0.0.0.0' do
        let(:params) { {
          'version'         => '1.2.3',
          'auto_unseal'     => true,
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0'
        } }

        it { is_expected.to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '0.0.0.0'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'stopped'
        ) }

        it { is_expected.not_to contain_class('profiles::vault::init') }
        it { is_expected.not_to contain_class('profiles::vault::seal') }
      end

      context 'with version => 4.5.6, auto_unseal => false, service_status => running, gpg_keys => { dcba6789 => { tag => baz, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" } } and service_address => 0.0.0.0' do
        let(:params) { {
          'version'         => '4.5.6',
          'auto_unseal'     => false,
          'service_status'  => 'running',
          'service_address' => '0.0.0.0',
          'gpg_keys'        => { 'dcba6789' => { 'tag' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" } }
        } }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '4.5.6'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '0.0.0.0'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        it { is_expected.to contain_class('profiles::vault::init').with(
          'auto_unseal' => false,
          'gpg_keys'    => { 'dcba6789' => { 'tag' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" } }
        ) }

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'auto_unseal' => false
        ) }
      end
    end
  end
end
