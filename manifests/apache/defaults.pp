class profiles::apache::defaults inherits ::profiles {

  $request_headers = [
                       'unset Proxy early',
                       'set X-Unique-Id %{UNIQUE_ID}e'
                     ]
  $setenvif        = [
                       'X-Forwarded-Proto "https" HTTPS=on',
                       'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                     ]
  $directories     = {
                       'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                       'allow_override' => 'All'
                     }
}
