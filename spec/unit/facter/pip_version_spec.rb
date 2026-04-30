describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'pip_version' do
    context 'without pip installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('pip -V 2> /dev/null') { '' }
      end

      it do
        expect(Facter.fact(:pip_version).value).to eq(nil)
      end
    end

    context 'with pip 24.0 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('pip -V 2> /dev/null') { 'pip 24.0 from /usr/lib/python3/dist-packages/pip (python 3.12)' }
      end

      it do
        expect(Facter.fact(:pip_version).value).to eq('24.0')
      end
    end

    context 'with pip 20.0.2 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('pip -V 2> /dev/null') { 'pip 20.0.2 from /usr/lib/python3/dist-packages/pip (python 3.8)' }
      end

      it do
        expect(Facter.fact(:pip_version).value).to eq('20.0.2')
      end
    end
  end
end
