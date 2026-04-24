require 'puppet'
require 'rspec/core/rake_task'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_fixtures/tasks'

PuppetSyntax.hieradata_paths = ["spec/support/hiera/data/*.yaml"]
PuppetSyntax.exclude_paths = ['spec/fixtures/**/*', 'vendor/**/*', 'spec/support/hiera/data/vault.yaml']

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_puppet_url_without_modules')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Default task prints the available targets."
task :default do
  system("rake -T")
end

RSpec::Core::RakeTask.new(:'spec:standalone') do |task|
  task.pattern = 'spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb'
end

desc "Install fixtures and run spec tests."
task :spec => [
  :'fixtures:prep',
  :'spec:standalone'
]

desc "Run syntax, lint, and spec tasks."
task :test => [
  :syntax,
  :lint,
  :spec
]

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end
