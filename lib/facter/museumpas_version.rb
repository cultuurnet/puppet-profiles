require_relative 'util/publiqapps.rb'

prefix = File.basename( __FILE__, '_version.rb' )

Facter.add("#{prefix}_version") do
  setcode do
    Facter::Util::PubliqApps.get_version prefix
  end
end
