class profiles::apache::logformats inherits ::profiles {

  $combined_json  = @("COMBINED_JSON"/L)
                    { \"remoteIP\": \"%a\", \
                    \"remoteLogname\": \"%l\", \
                    \"user\": \"%u\", \
                    \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \
                    \"request\": \"%r\", \
                    \"status\": %>s, \
                    \"responseBytes\": %b, \
                    \"referer\": \"%{Referer}i\", \
                    \"userAgent\": \"%{User-Agent}i\" \
                    }\
                    | COMBINED_JSON

  $extended_json  = @("EXTENDED_JSON"/L)
                    { \"remoteIP\": \"%{CLIENT_IP}e\", \
                    \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \
                    \"requestPath\": \"%U\", \
                    \"status\": \"%>s\", \
                    \"query\": \"%q\", \
                    \"method\": \"%m\", \
                    \"userAgent\": \"%{User-Agent}i\", \
                    \"referer\": \"%{Referer}i\", \
                    \"uniqueID\": \"%{UNIQUE_ID}e\", \
                    \"duration\": \"%{ms}T\" \
                    }\
                    | EXTENDED_JSON

  $x_fwd_for_extended_json  = @("X_FWD_FOR_EXTENDED_JSON"/L)
                    { \"remoteIP\": \"%{X-Forwarded-For}i\", \
                    \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \
                    \"requestPath\": \"%U\", \
                    \"status\": \"%>s\", \
                    \"query\": \"%q\", \
                    \"method\": \"%m\", \
                    \"userAgent\": \"%{User-Agent}i\", \
                    \"referer\": \"%{Referer}i\", \
                    \"uniqueID\": \"%{UNIQUE_ID}e\", \
                    \"duration\": \"%{ms}T\" \
                    }\
                    | EXTENDED_JSON

  $apikey_json    = @("APIKEY_JSON"/L)
                    { \"remoteIP\": \"%{CLIENT_IP}e\", \
                    \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \
                    \"requestPath\": \"%U\", \
                    \"status\": \"%>s\", \
                    \"query\": \"%q\", \
                    \"method\": \"%m\", \
                    \"userAgent\": \"%{User-Agent}i\", \
                    \"referer\": \"%{Referer}i\", \
                    \"uniqueID\": \"%{UNIQUE_ID}e\", \
                    \"duration\": \"%{ms}T\", \
                    \"apiKey\": \"%{APIKEY}e\", \
                    \"jwtToken\": \"%{JWTTOKEN}e\", \
                    \"clientProperties\": \"%{X-Client-Properties}i\" \
                    }\
                    | APIKEY_JSON

  $all  = {
            'combined_json'           => $combined_json,
            'extended_json'           => $extended_json,
            'x_fwd_for_extended_json' => $x_fwd_for_extended_json,
            'apikey_json'             => $apikey_json
          }
}
