describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'python_version' do
    context 'without python3 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('python3 -V 2> /dev/null') { '' }
      end

      it do
        expect(Facter.fact(:python_version).value).to eq(nil)
      end
    end

    context 'with python 3.12.3 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('python3 -V 2> /dev/null') { 'Python 3.12.3' }
      end

      it do
        expect(Facter.fact(:python_version).value).to eq('3.12.3')
      end
    end

    context 'with python 3.8.12 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('python3 -V 2> /dev/null') { 'Python 3.8.12' }
      end

      it do
        expect(Facter.fact(:python_version).value).to eq('3.8.12')
      end
    end
  end
end
