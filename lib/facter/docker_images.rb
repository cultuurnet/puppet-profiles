Facter.add('docker_images') do
  confine do
    Facter::Core::Execution::which('docker')
  end

  setcode do
    output = Facter::Core::Execution.execute('docker images --format json')

    unless output.empty?
      output.split("\n").map do |line|
        image = JSON.parse(line)

        { 'size' => image['Size'], 'repository' => image['Repository'], 'tag' => image['Tag'], 'id' => image['ID'], 'in_use' => image['Containers'] == '0' ? false : true }
      end
    end
  end
end
