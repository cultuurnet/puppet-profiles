Facter.add('docker_image_tag') do
  setcode do
    repos = Facter.value('docker_ecr_repos')
    next nil unless repos.is_a?(Hash) && !repos.empty?

    # Pipeline version tags are stamped as yyyy.MM.dd.HHmmss (see util.pipelineVersion()
    # in jenkins-global-library). Matching this shape lets us pick the immutable release
    # tag deterministically, rather than an arbitrary "other" tag on the same image
    # (which could just as easily resolve to 'latest').
    version_tag_pattern = /\A\d{4}\.\d{2}\.\d{2}\.\d{6}\z/

    repos.each_with_object({}) do |(name, config), result|
      region    = config['region']    || 'eu-west-1'
      image_tag = config['image_tag'] || 'latest'

      output = Facter::Core::Execution.execute(
        "aws ecr describe-images \
          --repository-name #{name} \
          --image-ids imageTag=#{image_tag} \
          --region #{region} \
          --query \"imageDetails[0].imageTags\" \
          --output text",
        on_fail: nil
      )

      tags = output.to_s.strip.split(/\s+/)
      version_tag = tags.find { |tag| tag =~ version_tag_pattern }

      # Fall back to the environment's own floating tag (e.g. 'acceptance')
      result[name] = version_tag || image_tag
    end
  end
end