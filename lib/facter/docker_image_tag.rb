Facter.add('docker_image_tag') do
  setcode do
    name   = Facter.value('docker_ecr_repo_name')
    region = Facter.value('docker_ecr_region') || 'eu-west-1'
    next nil unless name

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
    { name => tag } unless tag.nil? || tag.empty? || tag == 'None'
  end
end