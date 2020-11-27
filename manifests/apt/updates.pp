class profiles::apt::updates {

  contain ::profiles

  @profiles::apt::update { 'cultuurnet-tools': }
  @profiles::apt::update { 'php': }
  @profiles::apt::update { 'rabbitmq': }
  @profiles::apt::update { 'nodejs_10.x': }
  @profiles::apt::update { 'nodejs_12.x': }
  @profiles::apt::update { 'nodejs_14.x': }
  @profiles::apt::update { 'elasticsearch': }
  @profiles::apt::update { 'yarn': }
}
