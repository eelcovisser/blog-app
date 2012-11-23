module gallery/gallery-model

section photos

  entity Photo {
    original    :: Image
    large       :: Image
    medium      :: Image
    small       :: Image
    thumbnail   :: Image
    square      :: Image
    title       :: String
    description :: WikiText
    //created     :: DateTime (default=now())
    //modified    :: DateTime (default=now())
    
    function init() { 
      if(thumbnail == null) { resize(); }
    }
    function resize() {
      large     := copy(1024);
      medium    := copy(500);
      small     := copy(240);
      thumbnail := copy(100);
      square    := copy(75);
    }
    function copy(width: Int) : Image {
      var img := original.clone();
      var h := original.getHeight();
      var w := original.getWidth();
      if(h > 0) { img.resize(width, h * width / w); }
      return img;
    }
    function mayEdit() : Bool { return loggedIn(); }
    function mayView() : Bool { return true; }
    
    function filename() : String {
      return name + ".jpg";
    } 
    
    // set filename of image
    
  }
 
  
