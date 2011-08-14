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
    init{ application.update(); }
    main{
      form{
        formEntry("Title"){  
          input(application.title)  }
        formEntry("Email"){ 
          input(application.email)  }
        formEntry("Disqus Forum Id"){ 
          input(application.disqusForumId) } 
        formEntry("Analytics On") {
          input(application.analyticsOn)
        }
        formEntry("Google Analytics Account"){
          input(application.analyticsAccount)
        }
        formEntry("acceptRegistrations"){ 
          input(application.acceptRegistrations)  }
        formEntry("Footer"){ 
          input(application.footer) }
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
        if(isAdministrator()) { 
          includeWiki("adminSidebar")
          
          list{ 
            listitem{ navigate pageindex() { "Index" } }
            listitem{ navigate admin() { "Site Configuration" } } 
          }
        }
      }
    }
    define rssLink() {
      <link rel="alternate" type="application/rss+xml" title="RSS" href=navigate(feed("wiki")) />
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
      <div class="content">output(abbreviate(w.content.format(),500))</div>
    </div>
  }

section wiki rss

  define wikifeed() {
    rssWrapper(application.title, navigate(root()), navigate(feed("wiki")), "" as Text, now()){
      for(w: Wiki in recentlyModifiedPages(1,20,false)) {
        <item> 
          <title>output(w.title)</title>
          <link>output(link(w))</link>
          <description>output(abbreviate(w.content,2000) as WikiText)</description>
          //<description>output(w.content)</description>
          //<guid>output(link(w))</guid>
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
  rule page wiki(key : String, tab: String) { 
    true  
  } 
  rule page pageindex() { loggedIn() }
  
  rule template showWikiDiscussion(w: Wiki) { 
    w.mayComment()
    rule action edit() { w.mayComment() }
  }
  rule template editWikiDiscussion(w: Wiki) { w.mayComment() }
  
  rule ajaxtemplate showWiki(w: Wiki) { true }
  rule ajaxtemplate editWiki(w: Wiki)  { isWriter() }
  rule template wikiActions(w: Wiki) { 
    isCommenter() 
    rule action edit() { isWriter() }
    rule action publish() { isWriter() }
    rule action hide() { isWriter() }
  }
  
section wiki

  define page wiki(key: String, tab: String) {
    var w := findWiki(key)
    title{ output(wikiTitle(key)) }
    wikilayout{
      placeholder view{
        if(w == null || !w.mayView()) {
          unknownWiki(key)
        } else {
          case(tab) { 
            ""        { showWiki(w) }
            "discuss" { showWikiDiscussion(w) }
          }
        }
      }
    }
  }

  define ajax showWiki(w : Wiki) { 
    init{ w.update(); }
    <h1>output(w.title)</h1>
    output(w.content)
    wikiActions(w)
    byLine(w)
    attachments(w.attachments)
  }
  
  define ajax showWikiDiscussion(w : Wiki) { 
    action edit() { replace(view, editWikiDiscussion(w)); }
    <h1>output(w.title) " (Discussion)"</h1>
    output(w.discussion)
    block[class="wikiActions"] {
      submitlink edit() { "[Edit]" } " "
      navigate wiki(w.key,"") { "[Text]" }
    }
  }
  
  define ajax editWikiDiscussion(w: Wiki) {
    action save() { 
      w.modified();
      replace(view, showWikiDiscussion(w)); 
    }
    action cancel() { replace(view, showWikiDiscussion(w)); }
    <h1>output(w.title) " (Discussion)"</h1>
    form{
      input(w.discussion) 
      submit save() { "Save" } " "
    }
    submit cancel() { "Cancel" }
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
    action cancel() { replace(view, showWiki(w)); }
    <h1>output(w.title)</h1>
    form{
      formEntry("Key"){ input(w.key) }
      formEntry("Title"){ input(w.title) }
      formEntry("Text"){ input(w.content) }
      submit save() { "Save" }
    }
    submit cancel() { "Cancel" }
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
      navigate wiki(w.key, "discuss") { "[Discuss]" } " "
      if(w.public()) { 
        submitlink hide() { "[Hide]" }
      } else {
        submitlink publish() { "[Publish]" }
      }
    }
  }

section links to wiki page
      
  function link(w : Wiki): String {
    return navigate(wiki(w.key,"")); 
  }
  
  define output(w : Wiki) {
    navigate wiki(w.key,"") { if(w.title == "") { output(w.key) } else { output(w.title) } }
  }
  
  define unknownWiki(key : String) {
    action create() { createWiki(key); }
    <h1>output(key)</h1>
    par{ "That page does not exist, or you do not have permission to view it." }
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
  