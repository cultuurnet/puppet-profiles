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
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'host'/) }
      end
    end
  end
end
