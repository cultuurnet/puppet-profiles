describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'uitpas-balie_deployment_version' do
    context 'without packages' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'uitpas-balie-*' 2> /dev/null") { '' }
      end

      it do
        expect(Facter.fact('uitpas-balie_deployment_version').value).to eq(nil)
      end
    end

    context 'with package uitpas-balie-api:2022.07.12.124306+sha.28ee098:: and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'uitpas-balie-*' 2> /dev/null") { 'uitpas-balie-api;2022.07.12.124306+sha.28ee098;;;;;' }
      end

      it do
        expect(Facter.fact('uitpas-balie_deployment_version').value).to eq({"uitpas-balie-api" => { "commit" => "28ee098", "pipeline" => "2022.07.12.124306", "version" => "2022.07.12.124306+sha.28ee098", "build_url" => "", "homepage" => "" }})
      end
    end

    context 'with package uitpas-balie-api:2022.07.12.124306+sha.28ee098:2022.07.12.124306:28ee098 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'uitpas-balie-*' 2> /dev/null") { 'uitpas-balie-api;2022.07.12.124306+sha.28ee098;2022.07.12.124306;28ee098;https://jenkins.com/test/job;https://github.com/cultuurnet/test' }
      end

      it do
        expect(Facter.fact('uitpas-balie_deployment_version').value).to eq({"uitpas-balie-api" => { "commit" => "28ee098", "pipeline" => "2022.07.12.124306", "version" => "2022.07.12.124306+sha.28ee098", "build_url" => "https://jenkins.com/test/job", "homepage" => "https://github.com/cultuurnet/test" }})
      end
    end

    context 'with package uitpas-balie-api:2022.07.12.124306+sha.28ee098:: and uitpas-balie-frontend:2022.08.10.132311+sha.fbf71d6:: and no custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'uitpas-balie-*' 2> /dev/null") {
          "uitpas-balie-api;2022.07.12.124306+sha.28ee098;;;;\nuitpas-balie-frontend;2022.08.10.132311+sha.fbf71d6;;;;"
        }
      end

      it do
        expect(Facter.fact('uitpas-balie_deployment_version').value).to eq(
          {
            "uitpas-balie-api" => { "commit" => "28ee098", "pipeline" => "2022.07.12.124306", "version" => "2022.07.12.124306+sha.28ee098", "build_url" => "", "homepage" => "" },
            "uitpas-balie-frontend" => { "commit" => "fbf71d6", "pipeline" => "2022.08.10.132311", "version" => "2022.08.10.132311+sha.fbf71d6", "build_url" => "", "homepage" => "" }
          }
        )
      end
    end

    context 'with package uitpas-balie-api:2022.07.12.124306+sha.28ee098:2022.07.12.124306:28ee098 and uitpas-balie-frontend:2022.08.10.132311+sha.fbf71d6:2022.08.10.132311:fbf71d6 and custom metadata' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:exec).with("dpkg-query -f='${binary:Package};${Version};${Pipeline-Version};${Git-Ref};${Build-Url};${Homepage}\\n' -W 'uitpas-balie-*' 2> /dev/null") {
          "uitpas-balie-api;2022.07.12.124306+sha.28ee098;2022.07.12.124306;28ee098;;;\nuitpas-balie-frontend;2022.08.10.132311+sha.fbf71d6;2022.08.10.132311;fbf71d6;https://jenkins.com/test/job;https://github.com/cultuurnet/test"
        }
      end

      it do
        expect(Facter.fact('uitpas-balie_deployment_version').value).to eq(
          {
            "uitpas-balie-api" => { "commit" => "28ee098", "pipeline" => "2022.07.12.124306", "version" => "2022.07.12.124306+sha.28ee098", "build_url" => "", "homepage" => "" },
            "uitpas-balie-frontend" => { "commit" => "fbf71d6", "pipeline" => "2022.08.10.132311", "version" => "2022.08.10.132311+sha.fbf71d6", "build_url" => "https://jenkins.com/test/job", "homepage" => "https://github.com/cultuurnet/test" }
          }
        )
      end
    end
  end
end
