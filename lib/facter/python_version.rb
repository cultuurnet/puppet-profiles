Facter.add('python_version') do
  setcode do
    output = Facter::Util::Resolution.exec('python3 -V 2> /dev/null')

    unless output.nil?
      output[/^.* (\d+\.\d+\.\d+)\+?$/,1]
    end
  end
end
