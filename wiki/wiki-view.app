module wiki/wiki-view 
  
imports wiki/wiki-model
 
// todo: comments
// todo: attachments

access control rules 

  rule page admin() { isAdministrator() }
  
section frontpage

  define page root(){
    title { output(application.title) }   
    wikilayout {
      pageHeader{ output(application.title) }
      includeWiki("frontpage")
    }
  }
  
section administration
  
  define page admin() {
    init{ application.update(); }
    wikilayout{
      pageHeader{ "Site Configuration" }
      form{
        formEntry("Title"){  
          input(application.title) 
        }
        formEntry("Email"){ 
          input(application.email)
        }
        formEntry("Disqus Forum Id"){ 
          input(application.disqusForumId)
        } 
        formEntry("Analytics On") {
          input(application.analyticsOn)
        }
        formEntry("Google Analytics Account"){
          input(application.analyticsAccount)
        }
        formEntry("acceptRegistrations"){ 
          input(application.acceptRegistrations)
        }
        formEntry("Footer"){ 
          input(application.footer) [style="height:300px;"]
        }
        submit action{ return root(); } [class="btn btn-primary"] { "Save" }
      }
    }
  }
  
section wiki page layout
  
  define wikiAdminMenu() { 
    dropdownInNavbar("Admin"){
      dropdownMenu{
        dropdownMenuItem{ navigate pageindex() { "Index" } }
        dropdownMenuItem{ navigate admin() { "Site Configuration" } }
        dropdownMenuItem{ 
          navigate configmenubar(application.menubar(), "edit") { 
            "Configure Menubar" 
          }
        }
      }
    }
  }
  
  // define researchMenu() { 
  //   dropdownInNavbar("Research"){
  //     dropdownMenu{
  //       dropdownMenuItem{ navigate wiki("research","")     { "Overview"     } }
  //       dropdownMenuItem{ navigate wiki("publications","") { "Publications" } }
  //       dropdownMenuItem{ navigate wiki("projects","")     { "Projects"     } }
  //       dropdownMenuItem{ navigate wiki("software","")     { "Software"     } }
  //       dropdownMenuItem{ navigate wiki("students","")     { "Students"     } }
  //     }
  //   }
  // }
  // 
  // define teachingMenu() { 
  //   dropdownInNavbar("Teaching"){
  //     dropdownMenu{
  //       dropdownMenuItem{ navigate wiki("teaching","") { "Overview" } }
  //       dropdownMenuItem{ navigate wiki("courses","")  { "Courses"  } }
  //       dropdownMenuItem{ navigate wiki("theses","")   { "Theses"   } }
  //       dropdownMenuItem{ navigate wiki("students","") { "Students" } }
  //     }
  //   }
  // }
  // 
  // define bioMenu() { 
  //   dropdownInNavbar("Bio"){
  //     dropdownMenu{
  //       dropdownMenuItem{ navigate wiki("bio","")      { "Bio" } }
  //       dropdownMenuItem{ navigate wiki("cv","")       { "Curriculum Vitae"  } }
  //       dropdownMenuItem{ navigate wiki("students","") { "Students" } }
  //     }
  //   }
  // }
  
  define wikilayout() { 
    wikilayout(findCreateWiki("frontpage")) { elements }
  }

  define wikilayout(w: Wiki) {
    var menubar := w.menubar()
    define rssLink() {
      <link rel="alternate" type="application/rss+xml" title="RSS" href=navigate(feed("wiki")) />
    } 
    define brand() {
      if(menubar.brand != null) {
        navMenuItem(menubar.brand) [class="brand"]
      } else {
        navigate root() [class="brand"] { output(application.title) } 
      }
    }
    mainResponsive{ 
      navbarResponsive{       
        navItems{          
          dropdownMenubar(menubar)
          wikiAdminMenu
        }
      }
      gridContainer{
        messages
        elements 
      }
      footer{
        gridContainer{     
          gridRow{ footerMenubar(w.footerMenu()) }
          pagefooter
          pullRight{ signinoff }
        }
      }
      analytics
    }
  }

section search 

  define searchWiki() {
    var query: String
    action search() { if(query != "") { return wikisearch(query,1); } }
    div[class="searchPosts"]{
      form{
        input(query)
        submit search() [class="btn"] { iSearch " Search" }
      }
    }
  }

  define page wikisearch(query: String, index: Int) {
    var idx := max(1,index)
    title{ output(application.title) " | search" } 
    // todo pagination   
    //define pageIndexLink(i: Int, lab: String) { navigate index(i) { output(lab) } }
    wikilayout{ 
      pageHeader{ "Search Results for '" output(query) "'" }
      for(w: Wiki in searchWiki(query, 30, 30*(idx-1))) { wikiInSearch(w) }
      //pageIndex(index, b.postCount(loggedIn()), 10)
    }
  }
  
  define wikiInSearch(w: Wiki) {
    div[class="wikiInSearch"]{
      pageHeader3{ output(w) }
      div[class="content"]{
        output(abbreviate(w.content.format(),500))
      }
    }
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
    var w := findWiki(key);
    var f := if(w == null) findCreateWiki("frontpage") else w;
    title{ output(wikiTitle(key)) }
    wikilayout(f){
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
  
  define showWiki(key: String) {
    var w := findWiki(key)
    if(w != null) { showWiki(w) }
  }

  define ajax showWiki(w : Wiki) { 
    init{ w.update(); }
    pageHeader{ output(w.title) }
    div[class="wikiContent"]{ output(w.content) }
    byLine(w)
    wikiActions(w)
    attachments(w.attachments)
  }
  
  define ajax showWikiDiscussion(w : Wiki) { 
    action edit() { replace(view, editWikiDiscussion(w)); }
    pageHeader{ output(w.title) " (Discussion)" }
    output(w.discussion)
    block[class="wikiActions"] {
      submitlink edit() [class="btn"] { iPencil " Edit" } " "
      navigate wiki(w.key,"") { "Text" }
    }
  }
  
  define ajax editWikiDiscussion(w: Wiki) {
    action save() { 
      w.modified();
      replace(view, showWikiDiscussion(w)); 
    }
    action cancel() { replace(view, showWikiDiscussion(w)); }
    pageHeader{ output(w.title) " (Discussion)" }
    form{
      input(w.discussion) [style="height:500px;"]
      submit save() [class="btn btn-primary"] { "Save" } " "
    }
    submit cancel() [class="btn"] { "Cancel" }
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
    pageHeader{ output(w.title) }
    horizontalForm{
      controlGroup("Key"){ input(w.key) }
      controlGroup("Title"){ input(w.title) }
      controlGroup("Text"){ input(w.content) [style="height:500px;"] }
      formActions{
        submit save() [class="btn btn-primary"] { "Save" } " "
        navigate wiki(w.key,"") [class="btn"]  { "Cancel" }
      }
    }
  }

  define byLine(w: Wiki) {
    div[class="wikibyline"] {
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
    span[class="wikiActions"]{
      submitlink edit() [class="btn"] { iPencil " Edit" } " "
      navigate wiki(w.key, "discuss") [class="btn"]  { "Discuss" } " "
      if(w.public()) { 
        submitlink hide()  [class="btn"]  { "Hide" }
      } else {
        submitlink publish() [class="btn btn-primary"]  { "Publish" } 
      } " "
    }
  }

section links to wiki page

  define wikiLink(key: String) {
    navigate wiki(key, "") { output(key) }
  }
      
  function link(w : Wiki): String {
    return navigate(wiki(w.key,"")); 
  }
  
  define output(w : Wiki) {
    navigate wiki(w.key,"") { if(w.title == "") { output(w.key) } else { output(w.title) } }
  }
  
  define unknownWiki(key : String) {
    action create() { createWiki(key); }
    pageHeader{ output(key) }
    par{ "That page does not exist, or you do not have permission to view it." }
    par{
      if(mayCreateWiki()) {
        submit create() [class="btn btn-primary"] { "Create Wiki Page" }
      }
    }
  }
  
access control rules
  rule page pageindex() { true }
  
section page index
  
  define page pageindex() {
    wikilayout{
      pageHeader{"Wiki"}
      list{
        for(w : Wiki where w.mayView() order by w.title ) {
          listitem{ output(w) }
        }
      }
    }
  }
  