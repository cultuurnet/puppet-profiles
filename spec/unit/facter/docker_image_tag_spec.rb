describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'docker_image_tag' do
    context 'when the promoted image carries a pipeline-version tag alongside latest and the environment tag' do
      before :each do
        allow(Facter).to receive(:value).with('docker_ecr_repos').and_return(
          { 'uitdatabank/search-api' => { 'region' => 'eu-west-1', 'image_tag' => 'acceptance' } }
        )
        expect(Facter::Core::Execution).to receive(:execute)
          .with(a_string_matching(%r{--repository-name uitdatabank/search-api}), on_fail: nil)
          .and_return("acceptance\tlatest\t2026.08.04.120705")
      end

      it 'picks the pipeline-version tag rather than latest or the environment tag' do
        expect(Facter.fact('docker_image_tag').value).to eq(
          { 'uitdatabank/search-api' => '2026.08.04.120705' }
        )
      end
    end

    context 'when no tag on the image matches the pipeline-version shape' do
      before :each do
        allow(Facter).to receive(:value).with('docker_ecr_repos').and_return(
          { 'uitdatabank/search-api' => { 'region' => 'eu-west-1', 'image_tag' => 'acceptance' } }
        )
        expect(Facter::Core::Execution).to receive(:execute)
          .with(a_string_matching(%r{--repository-name uitdatabank/search-api}), on_fail: nil)
          .and_return("acceptance\tlatest")
      end

      it 'falls back to the environment tag rather than the global latest default' do
        expect(Facter.fact('docker_image_tag').value).to eq(
          { 'uitdatabank/search-api' => 'acceptance' }
        )
      end
    end

    context 'when the aws cli call fails' do
      before :each do
        allow(Facter).to receive(:value).with('docker_ecr_repos').and_return(
          { 'uitdatabank/search-api' => { 'region' => 'eu-west-1', 'image_tag' => 'acceptance' } }
        )
        expect(Facter::Core::Execution).to receive(:execute)
          .with(a_string_matching(%r{--repository-name uitdatabank/search-api}), on_fail: nil)
          .and_return(nil)
      end

      it 'falls back to the environment tag rather than the global latest default' do
        expect(Facter.fact('docker_image_tag').value).to eq(
          { 'uitdatabank/search-api' => 'acceptance' }
        )
      end
    end

    context 'with multiple repos, each resolving their own pipeline-version tag' do
      before :each do
        allow(Facter).to receive(:value).with('docker_ecr_repos').and_return(
          {
            'uitdatabank/search-api' => { 'region' => 'eu-west-1', 'image_tag' => 'acceptance' },
            'uitdatabank/entry-api'  => { 'region' => 'eu-west-1', 'image_tag' => 'acceptance' }
          }
        )
        expect(Facter::Core::Execution).to receive(:execute)
          .with(a_string_matching(%r{--repository-name uitdatabank/search-api}), on_fail: nil)
          .and_return("acceptance\tlatest\t2026.08.04.120705")
        expect(Facter::Core::Execution).to receive(:execute)
          .with(a_string_matching(%r{--repository-name uitdatabank/entry-api}), on_fail: nil)
          .and_return("acceptance\t2026.08.03.101500\tlatest")
      end

      it 'resolves the pipeline-version tag independently per repo' do
        expect(Facter.fact('docker_image_tag').value).to eq(
          {
            'uitdatabank/search-api' => '2026.08.04.120705',
            'uitdatabank/entry-api'  => '2026.08.03.101500'
          }
        )
      end
    end
  end
end
