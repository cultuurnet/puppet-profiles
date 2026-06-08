directories ['spec/defines', 'spec/classes', 'spec/functions', 'spec/unit', 'lib', 'manifests']

guard :rspec, cmd: 'bundle exec rspec', first_match: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/puppet/functions/(.+)\.rb$}) { |match| "spec/functions/#{match[1]}_spec.rb" }
  watch(%r{^lib/facter/(.+)\.rb$}) { |match| "spec/unit/facter/#{match[1]}_spec.rb" }
  watch(%r{^manifests/(.+)\.pp$}) { |match| File.exist?("spec/classes/#{match[1]}_spec.rb") ? "spec/classes/#{match[1]}_spec.rb" : "spec/defines/#{match[1]}_spec.rb" }
end

# vim:ft=ruby
