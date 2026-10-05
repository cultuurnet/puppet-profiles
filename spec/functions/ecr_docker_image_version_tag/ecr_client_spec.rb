require 'rspec'

require_relative '../../../lib/puppet/functions/ecr_docker_image_version_tag/ecr_client.rb'

describe ECRClient do
  describe '#describe_images' do
    context 'with an ECR image available' do
      let(:client) {
        Aws::ECR::Client.new(stub_responses: {
          describe_images:{
            image_details: [
              {
                registry_id: '123456789012',
                repository_name: 'uitdatabank/search-api',
                image_tags: ["acceptance", "latest", "2026.10.01.092900", "testing"]
              }, {
                registry_id: '123456789012',
                repository_name: 'uitdatabank/search-api',
                image_tags: ["production", "2026.09.30.092900"]
              }
            ]
          }
        })
      }

      it "calls the AWS ECR Client with the #describe_images instance method" do
        expect(client).to receive(:describe_images).once

        described_class.new(ecr_client: client).describe_images(registry_id: '123456789012', repository_name: 'uitdatabank/search-api')
      end

      it 'returns the image with attributes' do
        expected_result = {:image_details => [{:image_tags=>["acceptance", "latest", "2026.10.01.092900", "testing"], :registry_id=>"123456789012", :repository_name=>"uitdatabank/search-api"}, {:image_tags=>["production", "2026.09.30.092900"], :registry_id=>"123456789012", :repository_name=>"uitdatabank/search-api"}] }

        result = described_class.new(ecr_client: client).describe_images(registry_id: '123456789012', repository_name: 'uitdatabank/search-api')

        expect(result.to_h).to eq(expected_result)
      end
    end
  end
end
