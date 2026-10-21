describe 'profiles::museumpas::website' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'class locales ($default_locale = undef, $locales = []) {}' }
      let(:params) do
        {
          'database_password' => 'test_password',
          'database_host'     => 'db.example.com',
          'servername'        => 'acc.museumpassmusees.be',
          'deployment'        => false
        }
      end

      context 'without an upload override' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { is_expected.to contain_apache__vhost('acc.museumpassmusees.be_80').with(
          'custom_fragment' => %(<If "%{HTTP:Content-Type} =~ m#(?i)^multipart/form-data(?:[[:space:]]*;|[[:space:]]*$)#">\n  Require all denied\n</If>\n)
        ) }
      end

      context 'with multipart uploads allowed in hieradata' do
        let(:hiera_config) { 'spec/support/hiera/upload_overrides.yaml' }

        it { is_expected.to contain_class('profiles::apache').with('allow_multipart_form_uploads' => true) }
        it { is_expected.to contain_apache__vhost('acc.museumpassmusees.be_80').with('custom_fragment' => nil) }
      end
    end
  end
end
