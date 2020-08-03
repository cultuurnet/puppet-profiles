require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'museumpas_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact(:museumpas_version).value).to eq(nil)
      end
    end

    context 'with package museumpas-website:20200609124800+sha.692e9e0' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas*' 2> /dev/null") { 'museumpas-website:20200609124800+sha.692e9e0' }
      end

      it do
        expect(Facter.fact(:museumpas_version).value).to eq({"museumpas-website" => { "commit" => "692e9e0", "version" => "20200609124800+sha.692e9e0" }})
      end
    end

    context 'with package museumpas-database:20180810152730, museumpas-files:20180816150116 and museumpas-website:20200609124800+sha.692e9e0' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas*' 2> /dev/null") {
          "museumpas-database:20180810152730\nmuseumpas-files:20180816150116\nmuseumpas-website:20200609124800+sha.692e9e0"
        }
      end

      it do
        expect(Facter.fact(:museumpas_version).value).to eq(
          {
            "museumpas-database" => { "version" => "20180810152730" },
            "museumpas-files" => { "version" => "20180816150116" },
            "museumpas-website" => { "commit" => "692e9e0", "version" => "20200609124800+sha.692e9e0" }
          }
        )
      end
    end
  end
end
