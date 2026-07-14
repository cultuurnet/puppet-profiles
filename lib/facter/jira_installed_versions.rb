Facter.add('jira_installed_versions') do
  confine kernel: 'Linux'
  setcode do
    next [] unless File.directory?('/opt/jira')

    Dir.glob('/opt/jira/atlassian-jira-software-[0-9]*-standalone')
       .select { |dir| File.directory?(dir) }
       .sort_by { |dir| -File.mtime(dir).to_i }
       .map { |dir| File.basename(dir) }
  end
end
