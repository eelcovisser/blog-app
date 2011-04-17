module blog/blog-view

imports blog/blog-model
imports layout/layout-view 

access control rules
  rule template newBlog() { isAdministrator() }
  rule template newPost(b: Blog) { b.mayPost() }
   
section blog page layout

  define bloglayoutAux() {
    define rssLink() {
      <link rel="alternate" type="application/rss+xml" title="RSS" href=navigate(feed("wiki")) /> 
    }
    main{
      elements
    }
  }

  define bloglayout(b: Blog) {  
    define pageheader() { 
      <div class="title">link(b){ output(b.title) }</div>
    }
    define sidebar() {
      searchPosts(b)       
      sidebarSection{
        list{
          listitem{ navigate about() { "About" } }
          listitem{ navigate contact() { "Contact" } }
          listitem{ navigate index(1) { "Index" } }
          listitem{ navigate feed("blog") { "RSS" } }
        }
      }
      showLinks(b)
    	recentPosts(b)
    	blogAdmin(b)
    }
    bloglayoutAux{
      elements
    }
  }
  
  define recentPosts(b: Blog) {
  	sidebarSection{ 
      <h2>"Recent Posts"</h2>
      list{ for(p: Post in b.recentPosts(1,10,isWriter())){ listitem{ recentPost(p) } } }
    }
  }
  
  define link(b: Blog) {
    if(b.main) { navigate blog(1) { elements } } else { navigate other(b,1) { elements } }
  }

  define link(b: Blog, index: Int) {
    if(b.main) { navigate blog(index) { elements } } else { navigate other(b,index) { elements } }
  }
  function link(b: Blog, index: Int): String {
    if(b.main) { return navigate(blog(index)); } else { return navigate(other(b,index)); }
  }
  
section links

  define showLinks(b: Blog) {
    <h2>"Links"</h2>
    output(b.links)
  }
  
section about 

  define page about() {
    aboutBlog(mainBlog())
  }

  define aboutBlog(b: Blog) {
    title{ "About " output(b.title)}
    bloglayout(b){
      <h1>"About"</h1>
      output(b.about)
    }
  }
  
  define page contact() {
    contactBlog(mainBlog())
  }

  define contactBlog(b: Blog) {    
    title{ "Contact " output(b.title)}
    bloglayout(b){
      <h1>"Contact"</h1>
      output(b.contact)
    }
  }
    
section search

  define searchPosts(b: Blog) {
    var query: String
    action search() { if(query != "") { return search(b, query); } }
    <div class="searchPosts">
	    form{
	      input(query)
	      submit search() { "Search" }
	    }
    </div>
  }
  
  define page search(b: Blog, query: String) {
  	bloglayout(b){ 
  		for(p: Post in searchPost(query,30)) { postInSearch(p) }
  	}
    postCommentCountScript
  }
  
section blog table of contents

  define page index(index: Int) {
    indexBlog(mainBlog(),index)
  }
  
  define indexBlog(b: Blog, index: Int) {
  	title{ "Index " output(b.title) }
    define pageIndexLink(i: Int, lab: String) { navigate index(i) { output(lab) } }
    bloglayout(b){
      <h1>"Index"</h1>
      for(p: Post in b.recentPosts(index, 10, isWriter())) { postInIndex(p) }
      pageIndex(index, b.postCount(isWriter()), 10)
    }
    postCommentCountScript
  }
  
section blog rss

  define page feed(type: String) {
    case(type) {
  	  "blog" { blogrss(mainBlog()) }
  	  "wiki" { wikifeed() }
  	}
  }

  define blogrss(b: Blog) {
  	rssWrapper(b.title, link(b,1)){
  		for(p: Post in b.recentPosts(1,20,false)) {
  	    <item> 
          <title>output(p.title)</title>
          <link>output(permalink(p))</link>
          //<description>output(abbreviate(p.content,500))</description>
          <description>output(p.content)</description>
          <guid>output(permalink(p))</guid>
          <pubDate>output(p.created)</pubDate>
       </item>
  		}
  	}
  }

section blog front page
 
  define page blog(index: Int) {
    blog(mainBlog(), index)
  }
  
  define page other(b: Blog, index: Int) {
  	init{ if(b.main) { goto blog(1); } }
    blog(b, index) 
  }
  
  define blog(b: Blog,index: Int) {
    title{ output(b.title) " | page " output(index) }
    define pageIndexLink(i: Int, lab: String) { link(b,i) { output(lab) } }
    bloglayout(b){
      for(p: Post in b.recentPosts(index,5,isWriter())) { postInList(p) }    
      pageIndex(index, b.postCount(isWriter()), 5)
    }
    postCommentCountScript
  }
  
  define newBlog() {
    var name: String;
    action new() { newBlog(name); return blog(1); }
    form{ 
      input(name)
      submit new() { "Create New Blog" }
    }
  }
  
access control rules
  rule page blogadmin(b: Blog) { b.isAuthor() }
  rule page blogadminmain() { mainBlog().isAuthor() }
  
  rule template blogAdmin(b: Blog) { loggedIn() }
  
  rule template showHiddenPosts(b: Blog) { 
    loggedIn()
  }
   
section blog admin

  define blogAdmin(b: Blog) { 
    sidebarSection{
      <h2>"Internal"</h2>
      list{
	      listitem{ newPost(b) }
	      listitem{ showHiddenPosts(b) }
	      listitem {
	        if(b.main) { 
	          navigate blogadminmain() { "Blog Configuration" }
	        } else { 
	          navigate blogadmin(b){ "Blog Configuration" } 
	        }
	      }
      }
    }
  }
  
  define showHiddenPosts(b: Blog) {
    action toggle() { principal().toggleShowHiddenPosts(); }
    if(showHiddenPosts()) {
      submitlink toggle() { "[Hide Non-Public Posts]" }
    } else {
      submitlink toggle() { "[Show Non-Public Posts]" }
    }
  }
  
  define page blogadmin(b: Blog) {
    blogConfig(b)
  }
  
  define page blogadminmain() {
    blogConfig(mainBlog())
  }
    
  define blogConfig(b: Blog) {
    bloglayout(b) {
      form{
        formEntry("Blog Key"){ input(b.key) }
        formEntry("Blog Title"){ input(b.title) }
        formEntry("Blog Main"){ input(b.main) }
        formEntry("About"){ input(b.about) }
        formEntry("Contact"){ input(b.contact) }
        formEntry("Links"){ input(b.links) }
        submit action { return other(b,1); } { "Save" }
      }
    }
  }
  
access control rules

  rule template recentPost(p: Post)      { p.mayView()  }
  rule page post(p: Post, title: String) { p.mayView()  } 
  rule template newPost(b: Blog)         { b.isAuthor() }
  rule template postInSearch(p: Post)    { p.mayView()  }
  rule template postInList(p: Post)      { p.mayView()  }
  rule ajaxtemplate postView(p: Post)    { p.mayView()  }
  rule ajaxtemplate postActions(p: Post) { p.mayEdit()  }
  rule ajaxtemplate postEdit(p: Post)    { p.mayEdit()  }
  
section posts

  define permalink(p: Post) {
    navigate post(p, p.urlTitle) { elements }
  }
  function permalink(p: Post): URL {
    return navigate(post(p, p.urlTitle)); 
  }
  function plainLink(p: Post): URL {
    return navigate(post(p, "")); 
  }
  
  define recentPost(p: Post) {
    permalink(p){ 
      output(p.title) 
      if(!p.public) { " (unpublished)" }
    }
  }

  define newPost(b: Blog) {
    action new() { return post(b.addPost(),""); }
    submitlink new() { "[New Post]" }
  }
  
  define postByLine(p: Post) {
    <div class="postByline">
      if(p.publicComments()) { <span class="comments">postCommentCount(p) </span> }
      if(!p.public){ "not published | " }
      <span class="date">output(p.created.format("MMMM d, yyyy"))</span>
    </div>
  }
  
  define postContent(p: Post) {
    <div class="postContent">output(p.content)</div>
  }
  
  define postInIndex(p: Post) {
    <div class="postInIndex">
      <h1>permalink(p){ output(p.title) }</h1>
      postByLine(p)
    </div>
  }
  
  define postInSearch(p: Post) {
    <div class="postInSearch">
      <h1>permalink(p){ output(p.title) }</h1>
      postByLine(p)
      par{ output(abbreviate(p.content,250)) }
    </div>
  }
  
  define postInList(p: Post) {
    <div class="postInList">
      <h1>permalink(p){ output(p.title) }</h1>
      postByLine(p)
      postContent(p)
      //permalink(p){ "Read more" }
    </div>
  }

section post

  define page post(p: Post, title: String) {
    title{ output(p.title) }
    bloglayout(p.blog){
      placeholder view { postView(p) }
      postComments(p)
    }
    postCommentCountScript
  }
  
  define ajax postView(p: Post) {
    <div class="postView">
	    <h1>output(p.title)</h1>
	    postByLine(p)
	    postContent(p) 
	    postActions(p)
	  </div>
  }

  define ajax postEdit(p: Post) {
    action save() { p.modified(); replace(view, postView(p)); }
    <div class="postView">
      <h1>output(p.title)</h1>
      postByLine(p)
      form{
        formEntry("Title") { input(p.title) }
        formEntry("Content") { input(p.content) } 
        formEntry("Created") { input(p.created) }
        submit save() { "Save" }
      }
    </div>
  }
    
  define postActions(p: Post) {    
  	action edit() { replace(view, postEdit(p)); }
    action remove() { var b := p.blog; if(p.remove()) { return other(b,1); } }
    action withdraw() { p.withdraw(); }
    action publish() { p.publish(); }
    action undelete() { p.undelete(); }
    action showComments() { p.showComments1(); }
    action hideComments() { p.hideComments(); }
    <div class="postActions">
	  	submitlink edit() { "[Edit]" } 
	  	" "
	    if(p.public()) { 
	    	submitlink withdraw() { "[Withdraw]" } " "
	    	if(p.publicComments()){ 
	    		submitlink hideComments() { "[Hide Comments]" }
	    	} else {
	        submitlink showComments() { "[Show Comments]" }
	    	}
	    } else { 
	    	submitlink publish() { "[Publish]" }
	      " "
	      if(p.deleted()) { 
	        submitlink undelete() { "[Undelete]" } " "
		    	submitlink remove() { "[Permanently Delete]" } 
		    } else {
		    	submitlink remove() { "[Delete]" }
		    }
		  }
	  </div>
  }
  
section comments

  define postComments(p: Post) {
    var url := plainLink(p)
    var id := p.id
    var forum := application.disqusForumId
    if(p.publicComments()) {
	    <div id="disqus_thread"></div>
	    <script type="text/javascript">
		    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
		    var disqus_shortname = '~forum'; // required: replace example with your forum shortname
		
		    // The following are highly recommended additional parameters. Remove the slashes in front to use.
		    var disqus_identifier = '~id';
		    var disqus_url = '~url';
		
		    /* * * DON'T EDIT BELOW THIS LINE * * */
		    (function() {
		        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
		        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
		        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
		    })();
		  </script>
		  <noscript>"Please enable JavaScript to view the " <a href="http://disqus.com/?ref_noscript">"comments powered by Disqus."</a></noscript>
		  <a href="http://disqus.com" class="dsq-brlink">"blog comments powered by "<span class="logo-disqus">"Disqus"</span></a>
	  }
  }
  
  define postCommentCount(p: Post) {
    navigate url(permalink(p) + "#disqus_thread") { "comments" }
  }
  
  define postCommentCountScript() {
    var forum := application.disqusForumId
    <script type="text/javascript">
	    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
	    var disqus_shortname = '~forum'; // required: replace example with your forum shortname
	
	    /* * * DON'T EDIT BELOW THIS LINE * * */
	    (function () {
	        var s = document.createElement('script'); s.async = true;
	        s.type = 'text/javascript';
	        s.src = 'http://' + disqus_shortname + '.disqus.com/count.js';
	        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
	    }());
    </script>
  }
  