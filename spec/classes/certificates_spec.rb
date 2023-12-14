describe 'profiles::certificates' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Profiles::Certificate <| |>' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::certificates').with(
            'certificates' => {}
          ) }

          it { is_expected.to have_profiles__certificate_resource_count(0) }
        end

        context "with certificates => { 'foo.example.com' => { 'certificate_source' => '/tmp/cert/foo', 'key_source' => '/tmp/cert/foo.key' }, 'bar.example.com' => { 'certificate_source' => '/tmp/cert/bar', 'key_source' => '/tmp/cert/bar.key' }}" do
          let(:params) {
            {
              'certificates'             => {
                'foo.example.com' => { 'certificate_source' => '/tmp/cert/foo', 'key_source' => '/tmp/cert/foo.key' },
                'bar.example.com' => { 'certificate_source' => '/tmp/cert/bar', 'key_source' => '/tmp/cert/bar.key' }
              }
            }
          }

          it { is_expected.to contain_profiles__certificate('foo.example.com').with(
            'certificate_source' => '/tmp/cert/foo',
            'key_source'         => '/tmp/cert/foo.key'
          ) }

          it { is_expected.to contain_profiles__certificate('bar.example.com').with(
            'certificate_source' => '/tmp/cert/bar',
            'key_source'         => '/tmp/cert/bar.key'
          ) }
        end

        context "with certificates => { 'baz.example.com' => { 'certificate_source' => '/tmp/cert/baz', 'key_source' => '/tmp/cert/baz.key' }}" do
          let(:params) {
            {
              'certificates'             => {
                'baz.example.com' => { 'certificate_source' => '/tmp/cert/baz', 'key_source' => '/tmp/cert/baz.key' }
              }
            }
          }

          it { is_expected.to contain_profiles__certificate('baz.example.com').with(
            'certificate_source' => '/tmp/cert/baz',
            'key_source'         => '/tmp/cert/baz.key'
          ) }
        end
      end
    end
  end
end
