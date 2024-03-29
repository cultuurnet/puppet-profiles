module Facter
  module Util
    module PubliqApps
      def self.get_version(pattern)
        command = "dpkg-query -f='\$\{binary:Package\};\$\{Version\};\$\{Pipeline-Version\};\$\{Git-Ref\};\$\{Build-Url\};\$\{Homepage\}\\n' -W '#{pattern}-*' 2> /dev/null"
        versions = Facter::Util::Resolution.exec(command)

        return nil if versions.empty?

        versions.split("\n").inject({}) do |result, string|
          array = string.split(';', -1)

          component = array[0]
          version   = array[1]
          pipeline  = array[2].empty? ? version[/([.\d]+)\+?.*$/,1] : array[2]
          commit    = array[3].empty? ? version[/\+sha\.(.*)$/,1] : array[3]
          build_url = array[4]
          homepage  = array[5]

          version_hash = { 'version' => version, 'pipeline' => pipeline, 'commit' => commit, 'build_url' => build_url, 'homepage' => homepage }.reject { |k, v| v.nil? }
          result.merge({ component => version_hash })
        end
      end
    end
  end
end
