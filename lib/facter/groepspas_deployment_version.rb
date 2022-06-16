require_relative 'util/publiqapps.rb'

prefix = File.basename( __FILE__, '_deployment_version.rb')

Facter.add("#{prefix}_deployment_version") do
  setcode do
    Facter::Util::PubliqApps.get_version prefix
  end
end
