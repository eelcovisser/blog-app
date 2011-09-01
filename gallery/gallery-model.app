module gallery/gallery-model

section photos

  entity Photo {
    original    :: Image
    normal      :: Image
    thumbnail   :: Image
    title       :: String
    description :: WikiText
    created     :: DateTime (default=now())
    modified    :: DateTime (default=now())
    
    function add() { 
    	var h := original.getHeight();
    	var w := original.getWidth();
    	normal := original;
    	if(w > 600) { 
    		normal.resize(600, (h * 600) / w);
      }
    	thumbnail := original;
    	if(w > 150) {
    	  thumbnail.resize(150, (h * 150) / w);
    	}
    }
  }
  
