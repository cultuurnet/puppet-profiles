Facter.add('docker_image_tag') do
  setcode do
    repos = Facter.value('docker_ecr_repos')
    next nil unless repos.is_a?(Hash) && !repos.empty?

    repos.each_with_object({}) do |(name, config), result|
      region    = config['region']    || 'eu-west-1'
      image_tag = config['image_tag'] || 'latest'

      output = Facter::Core::Execution.execute(
        "aws ecr describe-images \
          --repository-name #{name} \
          --image-ids imageTag=#{image_tag} \
          --region #{region} \
          --query \"imageDetails[0].imageTags[?!= '#{image_tag}'] | [0]\" \
          --output text",
        on_fail: nil
      )

      tag = output&.strip
      result[name] = tag unless tag.nil? || tag.empty? || tag == 'None'
    end
  end
end