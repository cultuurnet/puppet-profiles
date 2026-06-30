class profiles::jenkins::buildtools::playwright inherits ::profiles {

  $dependencies = ['xvfb', 'libnss3', 'libxrandr2', 'libgbm1', 'libxkbcommon0',
                   'libxdamage1', 'libxcomposite1']

  $arch_dependencies = $facts['os']['release']['major'] ? {
                        '20.04' => ['libatspi2.0-0', 'libcups2', 'libatk-bridge2.0-0'],
                        default => ['libatspi2.0-0t64', 'libcups2t64', 'libatk-bridge2.0-0t64'],
  }

  package { $dependencies + $arch_dependencies:
    ensure => 'present'
  }
}
