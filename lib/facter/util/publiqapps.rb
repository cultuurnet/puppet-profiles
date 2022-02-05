module Facter
  module Util
    module PubliqApps
      def self.get_version(pattern)
        command = "dpkg-query -f='\$\{binary:Package\}:\$\{Version\}\\n' -W '#{pattern}*' 2> /dev/null"
        versions = Facter::Util::Resolution.exec(command)

        return nil if versions.empty?

        versions.split("\n").inject({}) do |result, string|
          component = string[/(.*):/,1]
          version = string[/:(.*)$/,1]
          pipeline = version[/([.\d]+)\+?.*$/,1]
          commit = version[/\+sha\.(.*)$/,1]

          version_hash = { 'version' => version, 'pipeline' => pipeline, 'commit' => commit }.reject { |k, v| v.nil? }
          result.merge({ component => version_hash })
        end
      end
    end
  end
end
