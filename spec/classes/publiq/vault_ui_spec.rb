describe 'profiles::publiq::vault_ui' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with certname => vault.example.com" do
        let(:params) { {
          'certname' => 'vault.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::vault_ui').with(
          'certname' => 'vault.example.com'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

        it { is_expected.to contain_puppet_certificate('vault.example.com').with(
          'ensure'               => 'present',
          'waitforcert'          => 60,
          'renewal_grace_period' => 5,
          'clean'                => true
        ) }

        it { is_expected.to contain_file('vault_ui_certificate_external_fact').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/facter/facts.d/vault_ui_certificate.txt',
          'content' => 'vault_ui_certificate_available=true'
        ) }

        it { is_expected.to contain_file('vault_ui_certificate_external_fact').that_requires('File[/etc/puppetlabs/facter/facts.d]') }
        it { is_expected.to contain_file('vault_ui_certificate_external_fact').that_requires('Puppet_certificate[vault.example.com]') }

        context "without fact vault_ui_certificate_available" do
          it { expect(exported_resources).not_to contain_profiles__vault__trusted_certificate('vault.example.com') }
        end

        context "with fact vault_ui_certificate_available" do
          let(:facts) { facts.merge({ 'vault_ui_certificate_available' => true }) }

          it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('vault.example.com').with(
            'policies' => ['puppet_certificate', 'ui_certificate']
          ) }
        end
      end

      context "with certname => foo.bar.local" do
        let(:params) { {
          'certname' => 'foo.bar.local'
        } }

        it { is_expected.to contain_puppet_certificate('foo.bar.local').with(
          'ensure'               => 'present',
          'waitforcert'          => 60,
          'renewal_grace_period' => 5,
          'clean'                => true
        ) }

        it { is_expected.to contain_file('vault_ui_certificate_external_fact').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/facter/facts.d/vault_ui_certificate.txt',
          'content' => 'vault_ui_certificate_available=true'
        ) }

        it { is_expected.to contain_file('vault_ui_certificate_external_fact').that_requires('Puppet_certificate[foo.bar.local]') }

        context "without fact vault_ui_certificate_available" do
          it { expect(exported_resources).not_to contain_profiles__vault__trusted_certificate('foo.bar.local') }
        end

        context "with fact vault_ui_certificate_available" do
          let(:facts) { facts.merge({ 'vault_ui_certificate_available' => true }) }

          it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('foo.bar.local').with(
            'policies' => ['puppet_certificate', 'ui_certificate']
          ) }
        end
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certname'/) }
      end
    end
  end
end
