class profiles::jenkins::buildtools::playwright inherits ::profiles {

  $dependencies = ['xvfb', 'libnss3', 'libxrandr2', 'libgbm1', 'libxkbcommon0',
                   'libxdamage1', 'libxcomposite1', 'libatspi2.0-0', 'libcups2',
                   'libatk-bridge2.0-0']

  package { $dependencies:
    ensure => 'present'
  }
}
