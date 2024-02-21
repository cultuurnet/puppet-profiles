describe 'profiles::timezone' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::timezone').with(
          'region'   => 'Etc',
          'locality' => 'UTC'
        ) }

        it { is_expected.to contain_class('timezone').with(
          'region'   => 'Etc',
          'locality' => 'UTC',
          'hwutc'    => true
        ) }
      end

      context "with region => Europe and locality => Brussels" do
        let(:params) { {
          'region'   => 'Europe',
          'locality' => 'Brussels'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('timezone').with(
          'region'   => 'Europe',
          'locality' => 'Brussels',
          'hwutc'    => true
        ) }
      end
    end
  end
end
