define profiles::media::rewrite (
  String                         $forwardingurl,
  Variant[String, Array[String]] $serveraliases = []
)  {

  include ::profiles
  include ::profiles::apache

  $servername = $title

  realize Group['www-data']
  realize User['www-data']
  realize File['/var/www']

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => '/var/www',
    serveraliases => $serveraliases,
    rewrites => [
      {
        'comment'      => 'Remove Dalicloud specific part of request path',
        'rewrite_cond' => '%{REQUEST_URI} ^/fis/(?:rest/|)download/ce126667652776f0e9e55160f12f5478(/.*)$',
        'rewrite_rule' => '^ - [E=IMGIX_REQUEST_URI:%1]'
      },
      {
        'comment'      => 'Pass all other request paths unaltered to Imgix',
        'rewrite_cond' => '%{REQUEST_URI} !^/fis/(?:rest/|)download/ce126667652776f0e9e55160f12f5478/.*$',
        'rewrite_rule' => '^ - [E=IMGIX_REQUEST_URI:%{REQUEST_URI}]'
      },
      {
        'comment'      => 'Transform parameter width',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)width=([^&]+)',
        'rewrite_rule' => '^ - [E=WIDTH:w=%1&,E=CROP:fit=fill&,E=BGCOLOR:bg=FFFFFF&]'
      },
      {
        'comment'      => 'Transform parameter maxwidth',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)maxwidth=([^&]+)',
        'rewrite_rule' => '^ - [E=WIDTH:w=%1&]'
      },
      {
        'comment'      => 'Transform parameter height',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)height=([^&]+)',
        'rewrite_rule' => '^ - [E=HEIGHT:h=%1&,E=CROP:fit=fill&,E=BGCOLOR:bg=FFFFFF&]'
      },
      {
        'comment'      => 'Transform parameter maxheight',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)maxheight=([^&]+)',
        'rewrite_rule' => '^ - [E=HEIGHT:h=%1&]'
      },
      {
        'comment'      => 'Transform parameter crop=auto',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)crop=auto(?:&|$)',
        'rewrite_rule' => '^ - [E=CROP:fit=crop&crop=entropy&,E=BGCOLOR:]'
      },
      {
        'comment'      => 'Transform parameter crop=edges',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)crop=edges(?:&|$)',
        'rewrite_rule' => '^ - [E=CROP:fit=crop&crop=edges&,E=BGCOLOR:]'
      },
      {
        'comment'      => 'Transform parameter crop=(<x1>,<y1>,<x2>,<y2>)',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)crop=\(([0-9|,]+)\)(?:&|$)',
        'rewrite_rule' => '^ - [E=RECT:rect=%1&]'
      },
      {
        'comment'      => 'Transform parameter format',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)format=([^&]+)',
        'rewrite_rule' => '^ - [E=FORMAT:fm=%1&]'
      },
      {
        'comment'      => 'Transform parameter flip=both',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)flip=both(?:&|$)',
        'rewrite_rule' => '^ - [E=FLIP:flip=hv&]'
      },
      {
        'comment'      => 'Transform parameter flip=(h|v)',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)flip=(h|v)(?:&|$)',
        'rewrite_rule' => '^ - [E=FLIP:flip=%1&]'
      },
      {
        'comment'      => 'Transform parameter rotate',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)rotate=([^&]+)',
        'rewrite_rule' => '^ - [E=ROTATE:rot=%1&]'
      },
      {
        'comment'      => 'Transform parameter paddingWidth',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)paddingWidth=([^&]+)',
        'rewrite_rule' => '^ - [E=PAD:pad=%1&,E=BGCOLOR:bg=FFFFFF&]'
      },
      {
        'comment'      => 'Transform parameter paddingColor',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)paddingColor=([^&]+)',
        'rewrite_rule' => '^ - [E=BGCOLOR:bg=%1&]'
      },
      {
        'comment'      => 'Transform parameter bgcolor',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)bgcolor=([^&]+)',
        'rewrite_rule' => '^ - [E=BGCOLOR:bg=%1&]'
      },
      {
        'comment'      => 'Transform parameter stretch=fill',
        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)stretch=fill(?:&|$)',
        'rewrite_rule' => '^ - [E=FIT:fit=scale&]'
      },
      {
        'comment'      => 'Create forwarding rule to image service',
        'rewrite_rule' => "^/(.*)$ ${forwardingurl}/\$1?auto=compress&auto=format&%{ENV:WIDTH}%{ENV:HEIGHT}%{ENV:CROP}%{ENV:RECT}%{ENV:FORMAT}%{ENV:FLIP}%{ENV:ROTATE}%{ENV:PAD}%{ENV:FIT}%{ENV:BGCOLOR} [R=301,L]"
      }
    ]
  }
}
