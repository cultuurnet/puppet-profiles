require 'resolv'

resolv_config = Resolv::DNS::Config.default_config_hash

Facter.add("nameservers") do
  setcode do
    resolv_config[:nameserver]
  end
end

Facter.add("searchdomains") do
  setcode do
    resolv_config[:search]
  end
end
