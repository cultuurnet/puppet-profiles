class profiles::apache::defaults inherits ::profiles {

  $request_headers = [
                       'unset Proxy early',
                       'set X-Unique-Id %{UNIQUE_ID}e'
                     ]

  $setenvif        = [
                       'X-Forwarded-Proto "https" HTTPS=on',
                       'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                     ]
}
