Facter.add(:nodejs_version) do
  setcode do
    output = Facter::Util::Resolution.exec('node -v 2> /dev/null')

    unless output.nil?
      output[/v(.*)$/,1]
    end
  end
end
