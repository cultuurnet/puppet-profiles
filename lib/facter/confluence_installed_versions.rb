Facter.add('confluence_installed_versions') do
  confine kernel: 'Linux'
  setcode do
    next [] unless File.directory?('/opt/confluence')

    Dir.glob('/opt/confluence/atlassian-confluence-[0-9]*')
       .select { |dir| File.directory?(dir) }
       .sort_by { |dir| -File.mtime(dir).to_i }
       .map { |dir| File.basename(dir) }
  end
end
