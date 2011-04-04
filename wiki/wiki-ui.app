module wiki/wiki-ui

// todo: comments
// todo: attachments
// todo: rss feed
// todo: mark wiki page as blog post

imports lib/pageindex


access control rules

  rule template showWiki(key : String) { true }
  rule template showWiki(w : Wiki) { true } 
  rule template unknownWiki(key : String) { 
    true
    rule action create() { loggedIn() }
  }
  rule page wiki(key : String) { true }
  rule page pageindex() { loggedIn() }  
  
  rule page blog(index : Int) { true }
  rule template post(w: Wiki) { true }
  
section wiki pages
 
  entity Wiki {
    key      :: String   (id, validate(isUniqueWiki(this), "A Wiki page with that name already exists."))
    title    :: String   (name, default=key)
    isBlog   :: Bool     (default=false)
    content  :: WikiText (default= "")
    created  :: DateTime (default=now())
    modified :: DateTime (default=now())
    authors  -> Set<User> 
    function modified()       { log("wiki modified"); modified := now(); authors.add(principal()); }
    function mayView() : Bool { return true; }
    function mayEdit() : Bool { return loggedIn(); }
  }
   
  function mayCreateWiki() : Bool { return loggedIn(); }
  
  function isBlog(key : String): Bool { var w := findWiki(key); return w != null && w.isBlog; }
  
section wiki

  define output(w : Wiki) {
    navigate wiki(w.key) {
      if(w.title == "") { output(w.key) } else { output(w.title) }
    }
  }
  
  define showWiki(key : String) {
    var w := findWiki(key)
    if(w == null) {
      unknownWiki(key)
    } else {
      showWiki(w)
    }
  }

  define showWiki(w : Wiki) { 
    section{
      header{ editableString(w.title) }
      editableText(w.content)
    }
  }

  define unknownWiki(key : String) {
    action create() {
      var w := Wiki{ key := key };
      w.save();
    }
    "No such wiki page found."
    if(mayCreateWiki()) {
      submit create() { "Create Wiki Page" }
    }
  }
  
  define byLine(key: String) { var w := findWiki(key); if(w != null) { byLine(w) } }
  
  define byLine(w: Wiki) {
    block[class:=byline] {
      "Created " output(w.created) 
      " Last modified " output(w.modified) 
      " Contributions by " for(u: User in w.authors) { output(u) } separated-by{ ", " }
    }
  }
  
  define page wiki(key : String) {
    main{
      showWiki(key)
      byLine(key)
    }
  }
  
section blog
  
  define page blog(index : Int) {
    var postCount := select count(w) from Wiki as w where w.isBlog
    main{
      for(w : Wiki where w.isBlog order by w.created desc limit 5 offset index*5) {
        post(w)
      }
      pageIndex(index, postCount, 5)
    }
  }
  
  define post(w : Wiki) {
    section{
      header{ output(w.title) }
      output(w.content)
      navigate wiki(w.key) { "Permalink" }
    }
  }
  
section page index
  
  define page pageindex() {
    main{
      header{"Index"}
      list{
        for(w : Wiki order by w.title) {
          listitem{ output(w) }
        }
      }
    }
  }
  