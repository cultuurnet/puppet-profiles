# frozen_string_literal: true

# @summary Returns the version tag attached to the docker image we provide the repository URL and a tag for.
Puppet::Functions.create_function(:ecr_docker_image_version_tag) do
  begin
    require 'aws-sdk-ecr'
  rescue LoadError => _e
    raise Puppet::DataBinding::LookupError, "Must install aws-sdk-ecr gem to use function ecr_docker_image_version_tag"
  end

  require_relative 'ecr_docker_image_version_tag/ecr_client'

  # @param image_repository
  #   The image repository you want to get the image version tag from.
  # @param source_tag
  #   The tag you want to use for image selection.
  #
  # @return [String]
  #
  # @example Example Usage:
  #   ecr_docker_image_version_tag('my_ecr/my_image', 'acceptance')
  dispatch :get_version_tag do
    required_param 'String', :image_repository
    required_param 'String', :source_tag
    return_type 'String'
  end

  def get_version_tag(image_repository, source_tag)
    # Pipeline version tags are stamped as yyyy.MM.dd.HHmmss (see util.pipelineVersion()
    # in jenkins-global-library). Matching this shape lets us pick the immutable release
    # tag deterministically, rather than an arbitrary "other" tag on the same image
    # (which could just as easily resolve to 'latest').
    version_tag_pattern = /\A\d{4}\.\d{2}\.\d{2}\.\d{6}\z/

    ecr_registry_id = image_repository.split('/')[0].split('.')[0]
    ecr_region      = image_repository.split('/')[0].split('.')[3]
    ecr_repository  = image_repository.split('/').drop(1).join('/')

    ecr = ECRClient.new(region: ecr_region)

    output = ecr.describe_images(
      registry_id: ecr_registry_id,
      repository_name: ecr_repository
    )

    raise Exception.new "No images found in #{image_repository}" if output[:image_details].empty?

    image = output[:image_details].filter { |image| image[:image_tags].include?(source_tag) }[0]

    raise Exception.new "No images found in #{image_repository} with tag #{source_tag}" if image.nil?

    version_tag = image[:image_tags].find { |tag| tag =~ version_tag_pattern }

    # If no version tag is found, fall back to the source_tag parameter
    version_tag || source_tag
  end
end
