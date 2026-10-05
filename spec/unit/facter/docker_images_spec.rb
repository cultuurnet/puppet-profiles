describe Facter::Util::Fact do
  before(:each) { Facter.clear }

  describe 'docker_images' do
    context 'when the docker command is available in the system PATH' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('docker').and_return(true)
      end

      context 'when no docker images are available' do
        before do
          allow(Facter::Core::Execution).to receive(:execute).with('docker images --format json').and_return('')
        end

        it 'returns nil' do
          expect(Facter.fact('docker_images').value).to be_nil
        end
      end

      context 'with one docker image that is used available' do
        before do
          allow(Facter::Core::Execution).to receive(:execute).with('docker images --format json').and_return(
            '{"Containers":"1","CreatedAt":"2026-07-15 23:57:33 +0000 UTC","CreatedSince":"2 months ago","Digest":"\u003cnone\u003e","ID":"4a73073bd557","Repository":"nginx","SharedSize":"N/A","Size":"93.6MB","Tag":"alpine","UniqueSize":"N/A"}'
          )
        end

        it 'returns an array with one element' do
          expect(Facter.fact('docker_images').value).to eq(
            [{ 'id' => '4a73073bd557', 'repository' => 'nginx', 'tag' => 'alpine', 'size' => '93.6MB', 'in_use' => true }]
          )
        end
      end

      context 'with three docker images available' do
        before do
          allow(Facter::Core::Execution).to receive(:execute).with('docker images --format json').and_return(
            '{"Containers":"4","CreatedAt":"2026-09-29 10:11:47 +0000 UTC","CreatedSince":"50 minutes ago","Digest":"\u003cnone\u003e","ID":"d156341b356a","Repository":"757200591793.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api","SharedSize":"N/A","Size":"888MB","Tag":"2026.09.29.100929","UniqueSize":"N/A"}
{"Containers":"0","CreatedAt":"2026-09-28 12:53:57 +0000 UTC","CreatedSince":"22 hours ago","Digest":"\u003cnone\u003e","ID":"08543926982e","Repository":"757200591793.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api","SharedSize":"N/A","Size":"888MB","Tag":"2026.09.28.125346","UniqueSize":"N/A"}
{"Containers":"1","CreatedAt":"2026-07-15 23:57:33 +0000 UTC","CreatedSince":"2 months ago","Digest":"\u003cnone\u003e","ID":"4a73073bd557","Repository":"nginx","SharedSize":"N/A","Size":"93.6MB","Tag":"alpine","UniqueSize":"N/A"}'
          )
        end

        it 'returns an array with three elements' do
          expect(Facter.fact('docker_images').value).to eq(
            [
              { 'id' => 'd156341b356a', 'repository' => '757200591793.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api', 'tag' => '2026.09.29.100929', 'size' => '888MB', 'in_use' => true },
              { 'id' => '08543926982e', 'repository' => '757200591793.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api', 'tag' => '2026.09.28.125346', 'size' => '888MB', 'in_use' => false },
              { 'id' => '4a73073bd557', 'repository' => 'nginx', 'tag' => 'alpine', 'size' => '93.6MB', 'in_use' => true }
            ]
          )
        end
      end
    end

    context 'when the docker command is not available in the system PATH' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('docker').and_return(false)
      end

      it 'returns nil' do
        expect(Facter.fact('docker_images').value).to be_nil
      end
    end
  end
end
