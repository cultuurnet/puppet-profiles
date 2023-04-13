RSpec.shared_examples "operating system support" do
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
    describe 'without any extra parameters on Ubuntu 16.04' do
      let(:facts) do
        {
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '16.04'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /Ubuntu 16.04 not supported/) }
    end
  end
end
