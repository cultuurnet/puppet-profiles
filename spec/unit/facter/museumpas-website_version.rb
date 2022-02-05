require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'museumpas-website_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas-website*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact('museumpas-website_version').value).to eq(nil)
      end
    end

    context 'with package museumpas-website:2020.06.09.124800+sha.692e9e0' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas-website*' 2> /dev/null") { 'museumpas-website:2020.06.09.124800+sha.692e9e0' }
      end

      it do
        expect(Facter.fact('museumpas-website_version').value).to eq({"museumpas-website" => { "commit" => "692e9e0", "pipeline" => "2020.06.09.124800", "version" => "2020.06.09.124800+sha.692e9e0" }})
      end
    end

    context 'with package museumpas-website-database:2018.08.10.152730, museumpas-website-files:2018.08.16.150116 and museumpas-website:2020.06.09.124800+sha.692e9e0' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'museumpas-website*' 2> /dev/null") {
          "museumpas-website-database:2018.08.10.152730\nmuseumpas-website-files:2018.08.16.150116\nmuseumpas-website:2020.06.09.124800+sha.692e9e0"
        }
      end

      it do
        expect(Facter.fact('museumpas-website_version').value).to eq(
          {
            "museumpas-website" => { "commit" => "692e9e0", "pipeline" => "2020.06.09.124800", "version" => "2020.06.09.124800+sha.692e9e0" },
            "museumpas-website-database" => { "version" => "2018.08.10.152730", "pipeline" => "2018.08.10.152730" },
            "museumpas-website-files" => { "version" => "2018.08.16.150116", "pipeline" => "2018.08.16.150116" }
          }
        )
      end
    end
  end
end
