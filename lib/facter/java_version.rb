Facter.add(:java_version) do
  setcode do
    if Facter::Core::Execution.which('java')
      version = Facter::Util::Resolution.exec('java -Xmx16m -version 2>&1').lines.find { |line| line.include?('version') }
    end
    version[%r{"(.*?)"}, 1] if version
  end
end
