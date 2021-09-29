ignore %r{^spec/fixtures/}

guard :rspec, cmd: 'bundle exec rspec', first_match: true do
  watch('spec/spec_helper.rb')    { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^manifests/(.+)\.pp$}) { |m| "spec/classes/#{m[1]}_spec.rb" }
  watch(%r{^manifests/(.+)\.pp$}) { |m| "spec/defines/#{m[1]}_spec.rb" }
end
