RSpec.shared_examples "operating system support" do |klass|
  context 'on supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(
            {
              'ec2_metadata' => { 'public-ipv4' => '5.6.7.8' }
            }
          )
        end

        it { is_expected.to contain_class(klass) }
      end
    end
  end

  context 'on an unsupported operating system' do
    describe 'without any extra parameters on RedHat' do
      let(:facts) do
        {
          :operatingsystem => 'RedHat'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'on an unsupported operating system release' do
    describe 'without any extra parameters on Ubuntu 12.04' do
      let(:facts) do
        {
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '12.04'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /Ubuntu 12.04 not supported/) }
    end
  end
end
