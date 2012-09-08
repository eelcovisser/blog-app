module wiki/wiki-view 
  
imports wiki/wiki-model
 
// todo: comments
// todo: attachments

access control rules 

  rule page admin() { isAdministrator() }
  rule template wikiAdminMenu() { isAdministrator() }
  
section frontpage

  page root(){
    title { output(application.title) }   
    wikilayout {
      pageHeader{ output(application.title) }
      gridRow{
        gridSpan(10, 2) { includeWiki("", "") }
      }
    }
  }
  
section administration
  
  page admin() {
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
  
  template wikiAdminMenu() { 
    dropdownInNavbar("Admin"){
      dropdownMenu{
        dropdownMenuItem{ navigate pageindex() { "Index" } }
        dropdownMenuItem{ navigate admin() { "Site Configuration" } }
        dropdownMenuItem{ 
          navigate configmenubar(application.menubar(), "edit") { 
            "Configure Menubar" 
          }
        }
        dropdownMenuItem{
          submitlink action{ updateWikis(); } { "Update Wikis" }
        }
      }
    }
  }
  
  template wikilayout() { 
    wikilayout(findCreateWiki("","")) { elements }
  }

  template wikilayout(w: Wiki) {
    define rssLink() {
      <link rel="alternate" type="application/rss+xml" title="RSS" href=navigate(feed("wiki")) ></link>
    }
    mainResponsive{ 
      navbar(w.menubar()) { wikiAdminMenu }
      gridContainer{
        messages
        elements 
      }
      footer(w.footerMenu())
    }
  }

section search 

  template searchWiki() {
    var query: String
    action search() { if(query != "") { return wikisearch(query,1); } }
    div[class="searchPosts"]{
      form{
        input(query)
        submit search() [class="btn"] { iSearch " Search" }
      }
    }
  }

  page wikisearch(query: String, index: Int) {
    var idx := max(1,index)
    title{ output(application.title) " | search" } 
    // todo pagination   
    //template pageIndexLink(i: Int, lab: String) { navigate index(i) { output(lab) } }
    wikilayout{ 
      pageHeader{ "Search Results for '" output(query) "'" }
      for(w: Wiki in searchWiki(query, 30, 30*(idx-1))) { wikiInSearch(w) }
      //pageIndex(index, b.postCount(loggedIn()), 10)
    }
  }
  
  template wikiInSearch(w: Wiki) {
    div[class="wikiInSearch"]{
      pageHeader3{ output(w) }
      div[class="content"]{
        output(abbreviate(w.content.format(),500))
      }
    }
  }

section wiki rss

  template wikifeed() {
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
  
  rule template unknownWiki(group: String, key : String) { 
    true
    rule action create() { isWriter() }
  }
  rule page wiki(group: String, key : String, tab: String) { 
    true  
  } 
  rule page pageindex() { loggedIn() }
  
  rule template showWikiDiscussion(w: Wiki) { 
    w.mayComment()
    rule action edit() { w.mayComment() }
  }
  rule template editWikiDiscussion(w: Wiki) { w.mayComment() }
  
  //rule ajaxtemplate showWiki(w: Wiki) { true }
  rule ajaxtemplate editWiki(w: Wiki)  { isWriter() }
  rule template wikiActions(w: Wiki) { 
    isCommenter() 
    rule action edit() { isWriter() }
    rule action publish() { isWriter() }
    rule action hide() { isWriter() }
  } 
  
section wiki

  define page wiki(group: String, key: String, tab: String) {
    var w := findWiki(group, key);
    var f := if(w == null) findWiki(group,"") else w;
    init{
      if(f == null) { f := findCreateWiki("", ""); }
    }
    title{ output(wikiTitle(key)) }
    wikilayout(f){
      if(key == "index") {
        groupIndex(group)
      } else {
        placeholder view{
          if(w == null || !w.mayView()) {
            unknownWiki(group, key)
          } else {
            case(tab) { 
              ""        { showWiki(w) }
              "discuss" { showWikiDiscussion(w) }           
            }
          }
        }
      }
    }
  }
  
  define groupIndex(group: String) {
    var g := findWikiGroup(group + ":")
    if(g == null) {
      "no such group"
    } else {
      pageHeader{ output(g.title) " Index" }
      gridRow{
        gridSpan(10,2) {
          groupIndexTable(g)
          navigate wikigroup(group, "edit") [class="btn"]{ iPencil " Edit" }
        }
      }
    }
  }
  
  define groupIndexTable(g: WikiGroup) {
    tableBordered{
      for(w: Wiki in g.pages()) {
        row{
          column{ output(w) }
          column{ output(w.modified) }
        }
      }
    }
  }
    
  template showWiki(group: String, key: String) {
    var w := findWiki(group, key)
    if(w != null) { showWiki(w) }
  }

  ajax template showWiki(w : Wiki) { 
    init{ w.update(); }
    pageHeader{ output(w.title) }
    gridRow{
      gridSpan(10,2){
        div[class="wikiContent"]{ output(w.content) }
        byLine(w)
        wikiActions(w)
        attachments(w.attachments)
      }
    }
  }
  
  ajax template showWikiDiscussion(w : Wiki) { 
    action edit() { replace(view, editWikiDiscussion(w)); }
    pageHeader{ output(w.title) " (Discussion)" }
    gridRow{
      gridSpan(10,2){ 
        output(w.discussion) 
        div[class="wikiActions"] {
          submitlink edit() [class="btn"] { iPencil " Edit" } " "
          nav(w) [class="btn"] { "Text" }
        }
      }
    }
  }
  
  ajax template editWikiDiscussion(w: Wiki) {
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
  
  template includeWiki(group: String, key: String) {
    var w := findCreateWiki(group, key);
    if(w != null) { output(w.content) }
  }

  ajax template editWiki(w: Wiki) {
    action save() { 
      w.modified();
      w.update();
      //replace(view, showWiki(w)); 
      return wiki(w.group.keyBase, w.keyBase, "");
    }
    action cancel() { replace(view, showWiki(w)); }
    pageHeader{ output(w.title) }
    horizontalForm{
      controlGroup("Key"){ input(w.keyBase) }
      controlGroup("Group"){ input(w.group) }
      controlGroup("Title"){ input(w.title) }
      controlGroup("Text"){ input(w.content) [style="height:500px;"] }
      formActions{
        submit save() [class="btn btn-primary"] { "Save" } " "
        nav(w) [class="btn"] { "Cancel" }
      }
    }
  }

  template byLine(w: Wiki) {
    div[class="wikibyline"] {
      "Created " output(w.created.format("MMMM d, yyyy")) 
      " | Last modified " output(w.modified.format("MMMM d, yyyy"))
      if(!w.public()) { " | not public " }
      " | Contributions by " for(u: User in w.authors) { output(u) } separated-by{ ", " }
    }
  }
  
  template wikiActions(w: Wiki) {
    action edit() { replace(view, editWiki(w)); }
    action publish() { w.show(); }
    action hide() { w.hide(); }
    span[class="wikiActions"]{
      submitlink edit() [class="btn"] { iPencil " Edit" } " "
      nav(w,"discuss") [class="btn"]  { "Discuss" } " "
      navigate wiki(w.group.keyBase, "index", "") [class="btn"] { "Index" } " "
      if(w.public()) { 
        submitlink hide()  [class="btn"]  { "Hide" }
      } else {
        submitlink publish() [class="btn btn-primary"]  { "Publish" } 
      } " "
    }
  }

section links to wiki page

  template wikiLink(group: String, key: String) {
    navigate wiki(group, key, "") { output(key) }
  }
      
  function link(w : Wiki): String {
    return navigate(wiki(w.group.keyBase, w.keyBase,"")); 
  }
  
  template output(w : Wiki) {
    nav(w)[all attributes]{ 
      output(if(w.title == "") w.keyBase else w.title) 
    }
  }
  
  template nav(w: Wiki) {
    nav(w,"") [all attributes] { elements }
  }
  
  template nav(w: Wiki, tab: String) {
    navigate wiki(w.group.keyBase, w.keyBase, tab) [all attributes] { elements }
  }
  
  template unknownWiki(group: String, key : String) {
    action create() { createWiki(group, key); }
    pageHeader{ output(key) }
    par{ "That page does not exist, or you do not have permission to view it." }
    par{
      if(mayCreateWiki()) {
        submit create() [class="btn btn-primary"] { "Create Wiki Page" }
      }
    }
  }
  
access control rules

  rule page wikigroup(group: String, tab: String) {
    tab == "" || isAdministrator()
  }

  rule page pageindex() { true }
  
section group

  template output(g: WikiGroup) {
    navigate wiki(g.keyBase, "index", "") { output(g.title) }
  }
  
  page wikigroup(group: String, tab: String) {
    var g := findWikiGroup(group + ":");
    wikilayout{
      pageHeader{ "Group: " output(g.title) }
      gridRow{
        gridSpan(10,2) { 
          if(tab == "edit") { 
            editGroup(g)
          } else {
            groupIndexTable(g)
            navigate wikigroup(group, "edit") [class="btn"] { iPencil "Edit" }
          }
        }
      }
    }
  }
  
  template editGroup(g: WikiGroup) { 
    action save() { 
      message("saved"); 
      g.update();
      return wikigroup(g.keyBase, "");
    }
    horizontalForm{
      controlGroup("Key"){
        input(g.keyBase)
      }
      controlGroup("Title"){
        input(g.title)
      }
      controlGroup("Menubar"){
        input(g.menubar)
      }
      controlGroup("Footer menu"){
        input(g.footerMenu)
      }
      formActions{
        submitlink save() [class="btn btn-primary"] { "Save" } " "
        navigate wikigroup(g.keyBase, "") [class="btn"] { "Cancel" }
      }
    }
  }
  
access control rules

  rule page pageindex() { true }
  
section page index
  
  page pageindex() {
    wikilayout{
      pageHeader{ "Index" }
      gridRow{
        gridSpan(10, 2){
          tableBordered{
            theader{
              th{ "Group" }
              th{ "Page" }
              th{ "Last Modified" }
            }
            for(w : Wiki where w.mayView() order by w.key asc ) {
              row{ 
                column{ output(w.group) }
                column{ output(w) }
                column{ output(w.modified) }
              }
            }
          }
        }
      }
    }
  }
  