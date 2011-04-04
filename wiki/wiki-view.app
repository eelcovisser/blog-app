module wiki/wiki-view

imports wiki/wiki-model

// todo: comments
// todo: attachments
// todo: rss feed
// todo: mark wiki page as blog post

imports lib/pageindex

  define wikilayout() {
    define sidebar() {
      searchWiki()      
      sidebarSection{
        includeWiki("sidebar")
        if(loggedIn()) { includeWiki("adminSidebar") }
      }
    }
    <div id="wiki">
    main{
      elements
    }
    </div>
  }

section search 

  define searchWiki() {
    var query: String
    action search() { if(query != "") { return wikisearch(query); } }
    <div class="searchPosts">
      form{
        input(query)
        submit search() { "Search" }
      }
    </div>    
  }

  define page wikisearch(query: String) {
    wikilayout{ 
      for(w: Wiki in searchWiki(query,30)) { wikiInSearch(w) }
    }
  }
  
  define wikiInSearch(w: Wiki) {
    output(w.title)
    output(abbreviate(w.content,200))
  }
  
access control rules

  rule template showWiki(key : String) { true }
  rule template showWiki(w : Wiki) { true } 
  rule template unknownWiki(key : String) { 
    true
    rule action create() { loggedIn() }
  }
  rule page wiki(key : String) { true }
  rule page pageindex() { loggedIn() } 
  
section wiki

  define page wiki(key : String) {
    wikilayout{
      showWiki(key)
      byLine(key)
    }
  }
  
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
  
  define includeWiki(key: String) {
    var w := findWiki(key)
    block[class="editableText"] {
      if(loggedIn()) { block[class="editLink"]{ navigate wiki(key) { "[edit]" } } }
      if(w != null) { output(w.content) }
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
      createWiki(key);
    }
    "No such wiki page found."
    if(mayCreateWiki()) {
      submit create() { "Create Wiki Page" }
    }
  }
  
  define byLine(key: String) { 
    var w := findWiki(key); if(w != null) { byLine(w) }
  }
  
  define byLine(w: Wiki) {
    block[class="byline"] {
      "Created " output(w.created.format("MMMM d, yyyy")) 
      " Last modified " output(w.modified.format("MMMM d, yyyy"))
      " Contributions by " for(u: User in w.authors) { output(u) } separated-by{ ", " }
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
  