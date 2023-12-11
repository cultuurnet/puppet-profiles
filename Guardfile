ignore %r{^spec/fixtures/}

guard :rspec, cmd: 'bundle exec rspec', first_match: true do
  watch('spec/spec_helper.rb')    { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^manifests/(.+)\.pp$}) { |m| if File.exists?("spec/classes/#{m[1]}_spec.rb"); "spec/classes/#{m[1]}_spec.rb" else "spec/defines/#{m[1]}_spec.rb" end }
end
