# frozen_string_literal: true

require 'aws-sdk-ecr'

class ECRClient

  attr_reader :ecr_client

  def initialize(region: nil, ecr_client: nil)
    @ecr_client = ecr_client || Aws::ECR::Client.new(region: region)
  end

  def describe_images(registry_id:, repository_name:)
    ecr_client.describe_images({
      registry_id: registry_id,
      repository_name: repository_name
    })
  end
end
