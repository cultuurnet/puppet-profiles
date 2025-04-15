#!/usr/bin/env ruby

require 'json'

APPDIR = File.expand_path(ARGV[0])

def app_files
  Dir.glob("#{APPDIR}/**/*").select { |fn| File.file?(fn) } - Dir.glob("#{APPDIR}/**/*.ico") - [ "#{APPDIR}/config.json" ]
end

def merge_config
  app_files.each do |file|
    data = File.read(file)

    config = JSON.parse(File.read("#{APPDIR}/config.json"))

    config.each do |key, value|
      if value.is_a?(String)
        data.gsub!(key, value)
      else
        data.gsub!("\"#{key}\"", value.to_json)
      end
    end

    File.open(file, "w") do |f|
      f.write(data.chomp)
    end
  end
end

merge_config
