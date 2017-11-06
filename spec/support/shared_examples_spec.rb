RSpec.shared_examples "operating system support" do |klass|
  context 'on supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to contain_class(klass) }
      end
    end
  end

  context 'on an unsupported operating system' do
    describe 'without any parameters on RedHat' do
      let(:facts) do
        {
          :operatingsystem => 'RedHat'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'on an unsupported operating system release' do
    describe 'without any parameters on Ubuntu 12.04' do
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
