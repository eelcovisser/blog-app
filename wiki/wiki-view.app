module wiki/wiki-view

imports wiki/wiki-model

// todo: comments
// todo: attachments
// todo: rss feed

access control rules

  rule page admin() { loggedIn() }
  
section application

  define page root(){
    title { output(application.title) }
    wikilayout() { showWiki("frontpage") }
  }
  
  define page admin() {
    main{
      form{
        formEntry("Title"){ input(application.title) }
        formEntry("Footer"){ input(application.footer) }
        submit action{ } { "Save" }
      }
    }
  }

imports lib/pageindex

  define wikilayout() {
    define sidebar() {
      searchWiki()
      navigate feed("wiki") { "RSS" }
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

section wiki rss

  define wikifeed() {
    rssWrapper(application.title, navigate(root())){
      for(w: Wiki in recentlyModifiedPages(1,20,false)) {
        <item> 
          <title>output(w.title)</title>
          <link>output(link(w))</link>
          <description>output(abbreviate(w.content,500))</description>
          <guid>output(link(w))</guid>
          <pubDate>output(w.modified)</pubDate>
       </item> 
      }
    }
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
  
  function link(w : Wiki): String {
    return navigate(wiki(w.key));
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
  