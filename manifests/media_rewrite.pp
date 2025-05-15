 class profiles::media_rewrite (
  Hash            $mediaurls = {}
 ) inherits ::profiles 
 {


  $mediaurls.each |$name, $attributes| {
     profiles::media::rewrite { $name:
      * => $attributes
    }
  }


   
 }
