describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'museumpas_deployment_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'museumpas-*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact(:museumpas_deployment_version).value).to eq(nil)
      end
    end

    context 'with package museumpas-website:20200609124800+sha.692e9e0 and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'museumpas-*' 2> /dev/null") { 'museumpas-website;20200609124800+sha.692e9e0;;;;' }
      end

      it do
        expect(Facter.fact(:museumpas_deployment_version).value).to eq({"museumpas-website" => { "commit" => "692e9e0", "pipeline" => "20200609124800", "version" => "20200609124800+sha.692e9e0", "build_url" => "", "homepage" => "" }})
      end
    end

    context 'with package museumpas-website:20200609124800+sha.692e9e0 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'museumpas-*' 2> /dev/null") { 'museumpas-website;20200609124800+sha.692e9e0;20200609124800;692e9e0;https://jenkins.com/test/job;;' }
      end

      it do
        expect(Facter.fact(:museumpas_deployment_version).value).to eq({"museumpas-website" => { "commit" => "692e9e0", "pipeline" => "20200609124800", "version" => "20200609124800+sha.692e9e0", "build_url" => "https://jenkins.com/test/job", "homepage" => "" }})
      end
    end

    context 'with package museumpas-database:20180810152730, museumpas-files:20180816150116 and museumpas-website:20200609124800+sha.692e9e0 and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'museumpas-*' 2> /dev/null") {
          "museumpas-database;20180810152730;;;;;\nmuseumpas-files;20180816150116;;;;;\nmuseumpas-website;20200609124800+sha.692e9e0;;;;"
        }
      end

      it do
        expect(Facter.fact(:museumpas_deployment_version).value).to eq(
          {
            "museumpas-database" => { "version" => "20180810152730", "pipeline" => "20180810152730", "build_url" => "", "homepage" => "" },
            "museumpas-files" => { "version" => "20180816150116", "pipeline" => "20180816150116", "build_url" => "", "homepage" => "" },
            "museumpas-website" => { "commit" => "692e9e0", "pipeline" => "20200609124800", "version" => "20200609124800+sha.692e9e0", "build_url" => "", "homepage" => "" }
          }
        )
      end
    end

    context 'with package museumpas-database:20180810152730, museumpas-files:20180816150116 and museumpas-website:20200609124800+sha.692e9e0 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'museumpas-*' 2> /dev/null") {
          "museumpas-database;20180810152730;20180810152730;;;;\nmuseumpas-files;20180816150116;20180816150116;;;;\nmuseumpas-website;20200609124800+sha.692e9e0;20200609124800;692e9e0;;https://github.com/cultuurnet/myrepo"
        }
      end

      it do
        expect(Facter.fact(:museumpas_deployment_version).value).to eq(
          {
            "museumpas-database" => { "version" => "20180810152730", "pipeline" => "20180810152730", "build_url" => "", "homepage" => "" },
            "museumpas-files" => { "version" => "20180816150116", "pipeline" => "20180816150116", "build_url" => "", "homepage" => "" },
            "museumpas-website" => { "commit" => "692e9e0", "pipeline" => "20200609124800", "version" => "20200609124800+sha.692e9e0", "build_url" => "", "homepage" => "https://github.com/cultuurnet/myrepo" }
          }
        )
      end
    end
  end
end
