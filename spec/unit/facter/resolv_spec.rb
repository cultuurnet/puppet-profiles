require 'spec_helper'

describe 'Facter::Util::Fact' do
  before(:each) { Facter.clear }

  describe 'nameservers' do
    context 'with nameservers set to 8.8.4.4 and 8.8.8.8' do
      before(:each) do
        allow(Resolv::DNS::Config).to receive(:default_config_hash).and_return({:nameserver => [ '8.8.4.4', '8.8.8.8'], :search => [ 'example.com'], :ndots => 1})
      end

      it { expect(Facter.fact(:nameservers).value).to eql([ '8.8.4.4', '8.8.8.8']) }
    end
  end

  describe 'searchdomains' do
    context 'with searchdomains set to example.com' do
      before(:each) do
        allow(Resolv::DNS::Config).to receive(:default_config_hash).and_return({:nameserver => [ '8.8.4.4', '8.8.8.8'], :search => [ 'example.com'], :ndots => 1})
      end

      it { expect(Facter.fact(:searchdomains).value).to eql([ 'example.com']) }
    end
  end
end
