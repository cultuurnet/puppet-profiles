class profiles::stages inherits ::profiles {

  stage {'pre':
    before => Stage['main']
  }

  stage {'post':
    require => Stage['main']
  }
}
