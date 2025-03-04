describe 'profiles::mysql::remote_server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with host => db.example.com" do
        let(:params) { {
          'host' => 'db.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('mysql-client') }

        it { is_expected.to contain_class('profiles::mysql::remote_instance').with(
          'host' => 'db.example.com'
        ) }

        it { is_expected.to contain_class('profiles::mysql::rds').with(
          'host' => 'db.example.com'
        ) }
      end

      context "with host => mydb.example.com" do
        let(:params) { {
          'host' => 'mydb.example.com'
        } }

        it { is_expected.to contain_class('profiles::mysql::remote_instance').with(
          'host' => 'mydb.example.com'
        ) }

        it { is_expected.to contain_class('profiles::mysql::rds').with(
          'host' => 'mydb.example.com'
        ) }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'host'/) }
      end
    end
  end
end
