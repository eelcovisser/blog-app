module wiki/wiki-view

imports wiki/wiki-model

// todo: comments
// todo: attachments

access control rules

  rule page admin() { isAdministrator() }
  
section application

  define page root(){
    title { output(application.title) }
    wikilayout() { includeWiki("frontpage") }
  }
  
  define page admin() {
    main{
      form{
        formEntry("Title"  ){ input(application.title)  }
        formEntry("Footer" ){ input(application.footer) }
        formEntry("Email"  ){ input(application.email)  }
        formEntry("acceptRegistrations"  ){ input(application.acceptRegistrations)  }
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
        if(isAdministrator()) { includeWiki("adminSidebar") }
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
    action search() { if(query != "") { return wikisearch(query,1); } }
    <div class="searchPosts">
      form{
        input(query)
        submit search() { "Search" }
      }
    </div>    
  }

  define page wikisearch(query: String, index: Int) {
    var idx := max(1,index)
    title{ output(application.title) " | search" } 
    // todo pagination   
    //define pageIndexLink(i: Int, lab: String) { navigate index(i) { output(lab) } }
    wikilayout{ 
      <h1>"Search Results for '" output(query) "'"</h1>
      for(w: Wiki in searchWiki(query, 30, 30*(idx-1))) { wikiInSearch(w) }
      //pageIndex(index, b.postCount(loggedIn()), 10)
    }
  }
  
  define wikiInSearch(w: Wiki) {
    <div class="wikiInSearch">
      <h2>output(w)</h2>
      <div class="content">output(abbreviate(w.content,200))</div>
    </div>
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

  rule template showWiki(w : Wiki) { w.mayView() } 
  rule template unknownWiki(key : String) { 
    true
    rule action create() { isWriter() }
  }
  rule page wiki(key : String) { true }
  rule page pageindex() { loggedIn() }
  
  rule ajaxtemplate showWiki(w: Wiki) { true }
  rule ajaxtemplate editWiki(w: Wiki)  { isWriter() }
  rule template wikiActions(w: Wiki) { isWriter() }
  
section wiki

  define page wiki(key : String) {
    var w := findWiki(key)
    title{ output(wikiTitle(key)) }
    wikilayout{
      placeholder view{
        if(w == null) {
          unknownWiki(key)
        } else {
          showWiki(w)
        }
      }
    }
  }

  define ajax showWiki(w : Wiki) { 
    <h1>output(w.title)</h1>
    output(w.content)          
    byLine(w)
    wikiActions(w)
  }
  
  define includeWiki(key: String) {
    var w := findCreateWiki(key);
    if(w != null) { output(w.content) }
  }

  define ajax editWiki(w: Wiki) {
    action save() { 
      w.modified();
      replace(view, showWiki(w)); 
    }
    form{
      formEntry("Key"){ input(w.key) }
      formEntry("Title"){ input(w.title) }
      formEntry("Text"){ input(w.content) }
      submit save() { "Save" }
    }
  }

  define byLine(w: Wiki) {
    block[class="byline"] {
      "Created " output(w.created.format("MMMM d, yyyy")) 
      " | Last modified " output(w.modified.format("MMMM d, yyyy"))
      if(!w.public()) { " | not public " }
      " | Contributions by " for(u: User in w.authors) { output(u) } separated-by{ ", " }
    }
  }
  
  define wikiActions(w: Wiki) {
    action edit() { replace(view, editWiki(w)); }
    action publish() { w.show(); }
    action hide() { w.hide(); }
    block[class="wikiActions"]{
      submitlink edit() { "[Edit]" } " "
      if(w.public()) { 
        submitlink hide() { "[Hide]" }
      } else {
        submitlink publish() { "[Publish]" }
      }
    }
  }

section links to wiki page
      
  function link(w : Wiki): String {
    return navigate(wiki(w.key)); 
  }
  
  define output(w : Wiki) {
    navigate wiki(w.key) { if(w.title == "") { output(w.key) } else { output(w.title) } }
  }
  
  define unknownWiki(key : String) {
    action create() { createWiki(key); }
    <h1>output(key)</h1>
    par{ "No page with key " output(key) " found." }
    par{
      if(mayCreateWiki()) {
        submit create() { "Create Wiki Page" }
      }
    }
  }
  
access control rules
  rule page pageindex() { true }
  
section page index
  
  define page pageindex() {
    wikilayout{
      header{"Wiki"}
      list{
        for(w : Wiki where w.mayView() order by w.title ) {
          listitem{ output(w) }
        }
      }
      header{"Administration"}
      list{
        //listitem{ navigate }
      }
    }
  }
  