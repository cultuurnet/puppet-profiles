class profiles::certificates (
  Hash $certificates = {}
) {

  contain ::profiles

  $certificates.each |$certificate, $sources| {
    @profiles::certificate { $certificate:
      * => $sources
    }
  }
}
