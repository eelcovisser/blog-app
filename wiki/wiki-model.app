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
  
section groups

  entity WikiGroup {
    key      :: String (id)
    keyBase  :: String (name)
    title    :: String (title)
    // created  :: DateTime (default=now())
    // modified :: DateTime (default=now())
        
    extend function setKeyBase(k: String) {
      key := k + ":";
    }
    function update() {
      if(keyBase == null) {
        keyBase := /:/.replaceAll("", key);
      }
      for(w: Wiki in pages()) {
        w.update();
      }
    }
    function pages(): List<Wiki> {
      return select w from Wiki as w where w.group = ~this order by w.key asc;
    }
  }
  
  function findCreateWikiGroup(key: String): WikiGroup {
    var group := findWikiGroup(key + ":");
    if(group == null) {
      group := WikiGroup{ key := key + ":" keyBase := key title := key };
    }
    return group;
  }
  
  function updateWikis() {
    for(g: WikiGroup) { g.update(); }
    for(w: Wiki) { w.update(); }
  }
  
section wiki pages 

  entity Wiki {
    key         :: String   (id, validate(isUniqueWiki(this), "A Wiki page with that name already exists."))
    keyBase     :: String 
    group       -> WikiGroup
    
    name :: String := (if(group != null) group.title + ": " else "") + title
    
    redirect    -> Wiki
    
    title       :: String   (default=key, searchable)
    content     :: WikiText (default= "", searchable)
    discussion  :: WikiText (default="", searchable)
    attachments -> Attachments
    // created     :: DateTime (default=now())
    // modified    :: DateTime (default=now())
    public      :: Bool     (default=true)
    authors     -> Set<User> 
    
    extend function setGroup(g: WikiGroup) {
      key := (if(g != null) g.key else ":") + keyBase;
    }
    
    extend function setKeyBase(k: String) {
      key := (if(group != null) group.key else ":") + k;
    }
    
    function modified() { 
      modified := now(); 
      authors.add(principal()); 
    }
    function mayView() : Bool { return public() || loggedIn(); }
    function mayEdit() : Bool { return loggedIn() && isWriter(); }
    function mayComment(): Bool { return loggedIn() && isCommenter(); }
    function public(): Bool {
      if(public == null) { public := true; }
      return public;
    }
    function show() { public := true; }
    function hide() { public := false; }
    
    function update() { 
      if(attachments == null) { attachments := newAttachments(); }
      if(discussion == null) { discussion := ""; }
      if(keyBase == null) { keyBase := key; }
      if(group == null) { group := findCreateWikiGroup("home"); }
      key := group.key + keyBase;
    }
    
    function moveTo(newgroup: WikiGroup) {
      var oldgroup := group;
      group := newgroup;
      var w := findCreateWiki(oldgroup.key, key);
      w.redirect := this;
    }
  }
  
  function createWiki(group: String, key: String): Wiki {
    var g := findCreateWikiGroup(group);
    var w := Wiki{ group := g key := g.key + key };
    w.keyBase := key;
    w.title := if(key != "") key else if(group != "") group else "Home";
    if(principal() != null) {
       w.content := "-- [[profile(" + principal().username + ")|" + principal().fullname + "]]";
    }
    w.save();
    return w;
  }
  
  function findWiki(group: String, key: String): Wiki {
    var w := findWiki(group + ":" + key);
    if(w != null) { w.update(); }
    return w;
  }
    
  function findCreateWiki(group: String, key: String): Wiki {
    var w := findWiki(group, key);
    if(w == null) { w := createWiki(group, key); }
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
      return select w from Wiki as w 
              where w.public is true
           order by w.modified desc limit n*(index-1),n;
    }
  }
  
  function wikiTitle(key: String): String {
    var w := findWiki(key);
    if(w == null) { return key; } else { return w.title; }
  }
  