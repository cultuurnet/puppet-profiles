class profiles::certificates (
  Hash $certificates = {}
) inherits ::profiles {

  $certificates.each |$certificate, $sources| {
    @profiles::certificate { $certificate:
      * => $sources
    }
  }
}
