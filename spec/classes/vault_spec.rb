describe 'profiles::vault' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with gpg_keys => { fingerprint => dcba6789, owner => baz, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" }' do
        let(:params) { {
          'gpg_keys' => { 'fingerprint' => 'dcba6789', 'owner' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" }
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault').with(
          'version'         => 'latest',
          'auto_unseal'     => false,
          'certname'        => nil,
          'service_status'  => 'running',
          'service_address' => '127.0.0.1',
          'key_threshold'   => 1,
          'gpg_keys'        => { 'fingerprint' => 'dcba6789', 'owner' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" }
        ) }

        it { is_expected.not_to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'certname'        => nil,
          'service_address' => '127.0.0.1'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        context 'without fact vault_initialized' do
          it { is_expected.to contain_class('profiles::vault::init').with(
            'key_threshold' => 1,
            'gpg_keys'      => { 'fingerprint' => 'dcba6789', 'owner' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" }
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

      context 'with version => 1.2.3, auto_unseal => true, certname => vault.example.com, service_status => stopped and service_address => 0.0.0.0' do
        let(:params) { {
          'version'         => '1.2.3',
          'auto_unseal'     => true,
          'certname'        => 'vault.example.com',
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0'
        } }

        it { is_expected.to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'certname'        => 'vault.example.com',
          'service_address' => '0.0.0.0'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'stopped'
        ) }

        it { is_expected.not_to contain_class('profiles::vault::init') }
        it { is_expected.not_to contain_class('profiles::vault::seal') }
      end

      context 'with version => 4.5.6, auto_unseal => false, service_status => running, key_threshold => 2, gpg_keys => [{ fingerprint => abcd1234, owner => foo, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" }, { fingerprint => cdef3456, owner => bar, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }] and service_address => 0.0.0.0' do
        let(:params) { {
          'version'         => '4.5.6',
          'service_status'  => 'running',
          'service_address' => '0.0.0.0',
          'auto_unseal'     => false,
          'key_threshold'   => 2,
          'gpg_keys'        => [
                                 { 'fingerprint' => 'abcd1234', 'owner' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                                 { 'fingerprint' => 'cdef3456', 'owner' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                               ]
        } }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '4.5.6'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'certname'        => nil,
          'service_address' => '0.0.0.0'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        it { is_expected.to contain_class('profiles::vault::init').with(
          'auto_unseal'   => false,
          'key_threshold' => 2,
          'gpg_keys'      => [
                               { 'fingerprint' => 'abcd1234', 'owner' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                               { 'fingerprint' => 'cdef3456', 'owner' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                             ]
        ) }

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'auto_unseal' => false
        ) }
      end

      context 'with auto_unseal => true and key_threshold => 3' do
        let(:params) { {
          'auto_unseal'   => true,
          'key_threshold' => 3
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with auto_unseal, key threshold cannot be higher than 1/) }
      end

      context 'with auto_unseal => false' do
        let(:params) { {
          'auto_unseal' => false
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /without auto_unseal, at least one GPG key has to be provided/) }
      end

      context 'with auto_unseal => false and gpg_keys => [{ fingerprint => abcd1234, owner => foo, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" }, { fingerprint => cdef3456, owner => bar, key => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }]' do
        let(:params) { {
          'auto_unseal' => false,
          'gpg_keys'    => [
                             { 'fingerprint' => 'abcd1234', 'owner' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                             { 'fingerprint' => 'cdef3456', 'owner' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                           ]
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with multiple key shares, key threshold must be higher than 1/) }
      end
    end
  end
end
