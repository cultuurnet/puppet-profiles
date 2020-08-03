require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'balie_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'balie*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact(:balie_version).value).to eq(nil)
      end
    end

    context 'with package balie-silex:20200728152530+sha.a926ff3' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'balie*' 2> /dev/null") { 'balie-silex:20200728152530+sha.a926ff3' }
      end

      it do
        expect(Facter.fact(:balie_version).value).to eq({"balie-silex" => { "commit" => "a926ff3", "version" => "20200728152530+sha.a926ff3" }})
      end
    end

    context 'with package balie:20200729132510, balie-silex:20200728152530+sha.a926ff3 and balie-silex:20200728152530+sha.a926ff3' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}\\n' -W 'balie*' 2> /dev/null") {
          "balie:20200729132510\nbalie-angular-app:20200729132510+sha.e3c29b6\nbalie-silex:20200728152530+sha.a926ff3"
        }
      end

      it do
        expect(Facter.fact(:balie_version).value).to eq(
          {
            "balie" => { "version" => "20200729132510" },
            "balie-angular-app" => { "commit" => "e3c29b6", "version" => "20200729132510+sha.e3c29b6" },
            "balie-silex" => { "commit" => "a926ff3", "version" => "20200728152530+sha.a926ff3" }
          }
        )
      end
    end
  end
end
