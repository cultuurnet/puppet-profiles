require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'nodejs_version' do
    context 'without nodejs installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('node -v 2> /dev/null') { '' }
      end

      it do
        expect(Facter.fact(:nodejs_version).value).to eq(nil)
      end
    end

    context 'with nodejs v14.16.0 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('node -v 2> /dev/null') { 'v14.16.0' }
      end

      it do
        expect(Facter.fact(:nodejs_version).value).to eq('14.16.0')
      end
    end

    context 'with nodejs v16.13.2 installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with('node -v 2> /dev/null') { 'v16.13.2' }
      end

      it do
        expect(Facter.fact(:nodejs_version).value).to eq('16.13.2')
      end
    end

  end
end
