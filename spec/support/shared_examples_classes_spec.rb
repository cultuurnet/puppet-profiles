RSpec.shared_examples "operating system support" do
  context 'on an unsupported operating system' do
    describe 'without any extra parameters on RedHat' do
      let(:facts) { {
        'os' => { 'name' => 'RedHat' }
      } }

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'on an unsupported operating system release' do
    describe 'without any extra parameters on Ubuntu 12.04' do
      let(:facts) { {
        'os' => { 'name' => 'Ubuntu', 'release' => { 'major' => '12.04' } }
      } }

      it { expect { catalogue }.to raise_error(Puppet::Error, /Ubuntu 12.04 not supported/) }
    end
  end
end
