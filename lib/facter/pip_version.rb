Facter.add('pip_version') do
  setcode do
    output = Facter::Util::Resolution.exec('pip -V 2> /dev/null')

    unless output.nil?
      output[/^pip (\d+\.\d+\.?\d*).*$/,1]
    end
  end
end
