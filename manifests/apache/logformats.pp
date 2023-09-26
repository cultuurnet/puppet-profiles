class profiles::apache::logformats inherits ::profiles {

  $all = {
           'combined_json'     => '{ \"remoteIP\": \"%a\", \"remoteLogname\": \"%l\", \"user\": \"%u\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"request\": \"%r\", \"status\": %>s, \"responseBytes\": %b, \"referer\": \"%{Referer}i\", \"userAgent\": \"%{User-Agent}i\" }',
           'extended_json' => '{ \"remoteIP\": \"%{CLIENT_IP}e\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"requestPath\": \"%U\", \"status\": \"%>s\", \"query\": \"%q\", \"method\": \"%m\", \"userAgent\": \"%{User-Agent}i\", \"referer\": \"%{Referer}i\", \"duration\": \"%{ms}T\"}'
  }
}
