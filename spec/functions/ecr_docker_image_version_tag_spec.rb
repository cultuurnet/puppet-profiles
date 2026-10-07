describe 'ecr_docker_image_version_tag' do
  it { is_expected.not_to be_nil }

  context 'without parameters' do
    it { is_expected.to run.with_params().and_raise_error(ArgumentError, %r{expects 2 arguments, got none}i) }
  end

  context 'with an ECR image on acceptance with version tag available' do
    let(:ecr_client_double) { instance_double(ECRClient) }

    before(:each) do
      allow(ECRClient).to receive(:new).and_return(ecr_client_double)

      allow(ecr_client_double).to receive(:describe_images).with(registry_id: '123456789012', repository_name: 'uitdatabank/search-api', image_tag: 'acceptance').and_return({:image_details => [{:image_tags=>["acceptance", "latest", "2026.10.01.092900", "testing"], :registry_id=>"123456789012", :repository_name=>"uitdatabank/search-api"}] })
    end

    context 'with parameters 123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api and acceptance' do
      it { is_expected.to run.with_params('123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api', 'acceptance').and_return('2026.10.01.092900') }
    end
  end

  context 'with an ECR image on testing with version tag available' do
    let(:ecr_client_double) { instance_double('ECRClient') }

    before(:each) do
      allow(ECRClient).to receive(:new).and_return(ecr_client_double)

      allow(ecr_client_double).to receive(:describe_images).with(registry_id: '123456789012', repository_name: 'uitdatabank/search-api', image_tag: 'testing').and_return({:image_details => [{:image_tags=>["acceptance", "latest", "2026.10.01.092900", "testing"], :registry_id=>"123456789012", :repository_name=>"uitdatabank/search-api"}] })
    end

    context 'with parameters 123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api and testing' do
      it { is_expected.to run.with_params('123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api', 'testing').and_return('2026.10.01.092900') }
    end
  end

  context 'with an ECR image on acceptance with no version tag available' do
    let(:ecr_client_double) { instance_double('ECRClient') }

    before(:each) do
      allow(ECRClient).to receive(:new).and_return(ecr_client_double)

      allow(ecr_client_double).to receive(:describe_images).with(registry_id: '123456789012', repository_name: 'uitdatabank/search-api', image_tag: 'acceptance').and_return({:image_details => [{:image_tags=>["acceptance", "latest", "foo"], :registry_id=>"123456789012", :repository_name=>"uitdatabank/search-api"}] })
    end

    context 'with parameters 123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api and acceptance' do
      it { is_expected.to run.with_params('123456789012.dkr.ecr.eu-west-1.amazonaws.com/uitdatabank/search-api', 'acceptance').and_return('acceptance') }
    end
  end
end
