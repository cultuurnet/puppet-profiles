Facter.add(:jenkins_pubkey) do
  key_file = '/var/lib/jenkins/.ssh/id_jenkins.pub'

  setcode do
    if File.exists?(key_file)
      data = File.read(key_file)

      key_type    = data.split(' ')[0]
      key_content = data.split(' ')[1]

      { 'type' => key_type, 'key' => key_content }
    end
  end
end
