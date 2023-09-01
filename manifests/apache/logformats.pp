class profiles::apache::logformats inherits ::profiles {

  $all = {
           'combined_json' => '{ \"client_ip\": \"%a\", \"remote_logname\": \"%l\", \"user\": \"%u\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"request\": \"%r\", \"status\": %>s, \"response_bytes\": %b, \"referer\": \"%{Referer}i\", \"user_agent\": \"%{User-Agent}i\" }'
  }
}
