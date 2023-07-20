class profiles::platform (

  Boolean $deployment = true
) {

  # Apache vhost nodig met php-fpm support

  if $deployment {
    include profiles::platform::deployment
  }
}
