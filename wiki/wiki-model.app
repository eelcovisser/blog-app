module wiki/wiki-model

section wiki pages 

  entity Wiki {
    key      :: String   (id, validate(isUniqueWiki(this), "A Wiki page with that name already exists."))
    title    :: String   (name, default=key, searchable)
    content  :: WikiText (default= "", searchable)
    created  :: DateTime (default=now())
    modified :: DateTime (default=now())
    authors  -> Set<User> 
    function modified()       { 
      modified := now(); authors.add(principal()); 
    }
    function mayView() : Bool { return true; }
    function mayEdit() : Bool { return loggedIn(); }
  }
  
  function createWiki(key: String): Wiki {
    var w := Wiki{ key := key title := key };
    w.save();
    return w;
  }
   
  function mayCreateWiki() : Bool { 
    return loggedIn(); 
  }
