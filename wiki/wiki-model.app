module wiki/wiki-model

section application administration

  entity Application {
    title  :: String
    footer :: WikiText
    email  :: Email
    acceptRegistrations :: Bool (default=true)
    disqusForumId :: String
    analyticsOn :: Bool (default=false)
    analyticsAccount :: String
    function update() { 
      if(analyticsOn == null) { analyticsOn := false; }
      if(acceptRegistrations == null) { acceptRegistrations := false; }
    }
  }
  
  var application := Application { 
    title  := "No Title" 
    footer := "no footer" 
  }
  
section wiki pages 

  entity Wiki {
    key      :: String   (id, validate(isUniqueWiki(this), "A Wiki page with that name already exists."))
    title    :: String   (name, default=key, searchable)
    content  :: WikiText (default= "", searchable)
    attachments -> Attachments
    created  :: DateTime (default=now())
    modified :: DateTime (default=now())
    public   :: Bool     (default=true)
    authors  -> Set<User> 
    function modified()       { 
      modified := now(); 
      authors.add(principal()); 
    }
    function mayView() : Bool { return public() || loggedIn(); }
    function mayEdit() : Bool { return loggedIn() && isWriter(); }
    function public(): Bool {
      if(public == null) { public := true; }
      return public;
    }
    function show() { public := true; }
    function hide() { public := false; }
    function update() { 
      if(attachments == null) { attachments := newAttachments(); }
    }
  }
  
  function createWiki(key: String): Wiki {
    var w := Wiki{ key := key title := key };
    if(principal() != null) {
       w.content := "-- [[profile(" + principal().username + ")|" + principal().fullname + "]]";
    }
    w.save();
    return w;
  }
  
  function findCreateWiki(key: String): Wiki {
    var w := findWiki(key);
    if(w == null) { w := createWiki(key); }
    return w;
  }
   
  function mayCreateWiki() : Bool { 
    return loggedIn(); 
  }

  function recentlyModifiedPages(index: Int, n: Int, includePrivate: Bool): List<Wiki> {
    if(includePrivate) {
      return select w from Wiki as w 
           order by w.modified desc limit n*(index-1),n;
    } else {
      return select w from Wiki as w where w.public is true
           order by w.modified desc limit n*(index-1),n;
    }
  }
  
  function wikiTitle(key: String): String {
    var w := findWiki(key);
    if(w == null) { return key; } else { return w.title; }
  }
  