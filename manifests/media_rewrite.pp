 class profiles::media_rewrite (
  Hash            $mediaUrls = {}
 ) inherits ::profiles 
 {


  $mediaUrls.each |$name, $attributes| {
     profiles::media::rewrite { $name:
      * => $attributes
    }
  }


   
 }
