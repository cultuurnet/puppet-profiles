Facter.add('docker_image_tag') do
  setcode do
    repos = Facter.value('docker_ecr_repos')
    next nil unless repos.is_a?(Hash) && !repos.empty?

    repos.each_with_object({}) do |(name, region), result|
      region ||= 'eu-west-1'
      output = Facter::Core::Execution.execute(
        "aws ecr describe-images \
          --repository-name #{name} \
          --image-ids imageTag=latest \
          --region #{region} \
          --query \"imageDetails[0].imageTags[?!= 'latest'] | [0]\" \
          --output text",
        on_fail: nil
      )

      tag = output&.strip
      result[name] = tag unless tag.nil? || tag.empty? || tag == 'None'
    end
  end
end