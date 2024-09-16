class profiles::atlassian (
  Boolean $install_jira       = true,
  Boolean $install_confluence = true,
) inherits ::profiles {

  if $install_jira {
    include ::profiles::atlassian::jira
  }

  if $install_confluence {
    include ::profiles::atlassian::confluence
  }
}

