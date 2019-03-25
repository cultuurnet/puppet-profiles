require "spec_helper"

describe "Facter::Util::Fact" do
  before {
    Facter.clear
    allow(Resolv::DNS::Config).to receive(:default_config_hash).and_return({:nameserver=>["8.8.4.4", "8.8.8.8"], :search=>["example.com"], :ndots=>1})
  }

  describe "nameservers" do
    it do
      expect(Facter.fact(:nameservers).value).to eql([ "8.8.4.4", "8.8.8.8"])
    end
  end

  describe "searchdomains" do
    it do
      expect(Facter.fact(:searchdomains).value).to eql([ "example.com"])
    end
  end
end
