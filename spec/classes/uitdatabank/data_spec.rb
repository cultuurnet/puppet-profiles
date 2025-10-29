describe 'profiles::uitdatabank::data' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('amqp-tools') }

        it { is_expected.to contain_class('profiles::uitdatabank::data').with(
          'redis' => true,
          'mysql' => true
        ) }

        it { is_expected.to contain_class('profiles::redis') }
        it { is_expected.to contain_class('profiles::mysql::server') }
      end

      context "with mysql => false" do
        let(:params) { {
          'mysql' => false
        } }

        it { is_expected.to contain_class('profiles::redis') }
        it { is_expected.not_to contain_class('profiles::mysql::server') }
      end

      context "with redis => false" do
        let(:params) { {
          'redis' => false
        } }

        it { is_expected.not_to contain_class('profiles::redis') }
        it { is_expected.to contain_class('profiles::mysql::server') }
      end
    end
  end
end
