require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'balie_deployment_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}:${Pipeline-Version}:${Git-Ref}\\n' -W 'balie*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact(:balie_deployment_version).value).to eq(nil)
      end
    end

    context 'with package balie-silex:20200728152530+sha.a926ff3 and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}:${Pipeline-Version}:${Git-Ref}\\n' -W 'balie*' 2> /dev/null") { 'balie-silex:20200728152530+sha.a926ff3::' }
      end

      it do
        expect(Facter.fact(:balie_deployment_version).value).to eq({"balie-silex" => { "commit" => "a926ff3", "pipeline" => "20200728152530", "version" => "20200728152530+sha.a926ff3" }})
      end
    end

    context 'with package balie-silex:20200728152530+sha.a926ff3 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}:${Pipeline-Version}:${Git-Ref}\\n' -W 'balie*' 2> /dev/null") { 'balie-silex:20200728152530+sha.a926ff3:20200728152530:a926ff3' }
      end

      it do
        expect(Facter.fact(:balie_deployment_version).value).to eq({"balie-silex" => { "commit" => "a926ff3", "pipeline" => "20200728152530", "version" => "20200728152530+sha.a926ff3" }})
      end
    end

    context 'with package balie-angular-app:20200729132510+sha.e3c29b6 and balie-silex:20200728152530+sha.a926ff3 and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}:${Pipeline-Version}:${Git-Ref}\\n' -W 'balie*' 2> /dev/null") {
          "balie-angular-app:20200729132510+sha.e3c29b6::\nbalie-silex:20200728152530+sha.a926ff3::"
        }
      end

      it do
        expect(Facter.fact(:balie_deployment_version).value).to eq(
          {
            "balie-angular-app" => { "commit" => "e3c29b6", "pipeline" => "20200729132510", "version" => "20200729132510+sha.e3c29b6" },
            "balie-silex" => { "commit" => "a926ff3", "pipeline" => "20200728152530", "version" => "20200728152530+sha.a926ff3" }
          }
        )
      end
    end

    context 'with package balie-angular-app:20200729132510+sha.e3c29b6 and balie-silex:20200728152530+sha.a926ff3 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package}:${Version}:${Pipeline-Version}:${Git-Ref}\\n' -W 'balie*' 2> /dev/null") {
          "balie-angular-app:20200729132510+sha.e3c29b6:20200729132510:e3c29b6\nbalie-silex:20200728152530+sha.a926ff3:20200728152530:a926ff3"
        }
      end

      it do
        expect(Facter.fact(:balie_deployment_version).value).to eq(
          {
            "balie-angular-app" => { "commit" => "e3c29b6", "pipeline" => "20200729132510", "version" => "20200729132510+sha.e3c29b6" },
            "balie-silex" => { "commit" => "a926ff3", "pipeline" => "20200728152530", "version" => "20200728152530+sha.a926ff3" }
          }
        )
      end
    end
  end
end
