module blog/blog-view

imports blog/blog-model
imports layout/layout-view

access control rules
  rule template newBlog() { loggedIn() }
  rule template newPost(b: Blog) { loggedIn() }
  
section blog page layout

  define bloglayout(b: Blog) {
    define pageheader() { 
      <div class="title">link(b){ output(b.title) }</div>
    }
    define sidebar() {
      searchPosts(b)
      showLinks(b)
    	recentPosts(b)
    	blogAdmin(b)
    }
    main{
      elements
    }
  }
  
  define recentPosts(b: Blog) {
  	sidebarSection{ 
      <h2>"Recent Posts"</h2>
      list{ for(p: Post in b.recentPosts(1,10,loggedIn())){ listitem{ recentPost(p) } } }
    }
  }
  
  define link(b: Blog) {
    if(b.main) { navigate blog(1) { elements } } else { navigate other(b,1) { elements } }
  }

  define link(b: Blog, index: Int) {
    if(b.main) { navigate blog(index) { elements } } else { navigate other(b,index) { elements } }
  }
  
section links

  define showLinks(b: Blog) {
    <h2>"Links"</h2>
    output(b.links)
  }
  
section about 

  define about() {
    aboutBlog(mainBlog())
  }

  define aboutBlog(b: Blog) {
    bloglayout(b){
      output(b.about)
    }
  }
  
  define contact() {
    contactBlog(mainBlog())
  }

  define contactBlog(b: Blog) {
    bloglayout(b){
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
      for(p: Post in b.recentPosts(index,5,loggedIn())) { postInList(p) }    
      pageIndex(index, b.postCount(loggedIn()), 5)
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
  rule page blogadmin(b: Blog) { loggedIn() }
  rule page blogadminmain() { loggedIn() }
  
section blog admin

  define blogAdmin(b: Blog) { 
    sidebarSection{
      newPost(b)  
      if(b.main) { 
        navigate blogadminmain() { "[Admin]" }
      } else { 
        navigate blogadmin(b){ "[Admin]" } 
      }
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

  rule template recentPost(p: Post) { p.mayView() }
  rule page post(p: Post, title: String) { p.mayView() } 
  rule template newPost(b: Blog) { loggedIn() }
  rule template postInSearch(p: Post) { p.mayView() }
  rule template postInList(p: Post) { p.mayView() }
  rule ajaxtemplate postView(p: Post) { 
    p.mayView()
    rule action edit(){ p.mayEdit() }
  }
  rule ajaxtemplate postEdit(p: Post) { p.mayEdit() }
  
section posts

  define permalink(p: Post) {
    navigate post(p, p.urlTitle) { elements }
  }
  function permalink(p: Post): URL {
    return navigate(post(p, p.urlTitle)); 
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
  
  define page post(p: Post, title: String) {
    title{ output(p.title) }
    bloglayout(p.blog){
    	placeholder view { postView(p) }
    	postComments(p)
    }
  }
  
  define postByLine(p: Post) {
    <div class="postByline">
      if(p.showComments()) { postCommentCount(p) " | " }
      if(!p.public){ "not published | " }
      output(p.created.format("MMMM d, yyyy"))
    </div>
  }
  
  define postContent(p: Post) {
    <div class="postContent">output(p.content)</div>
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

  define ajax postView(p: Post) {
    action edit() { replace(view, postEdit(p)); }
    <div class="postView">
	    <h1>output(p.title)</h1>
	    postByLine(p)
	    postContent(p)
	    submitlink edit() { "[Edit]" }
	  </div>
  }
  
  define ajax postEdit(p: Post) {
    action save() { p.modified(); replace(view, postView(p)); }
    form{
      formEntry("Title") { input(p.title) }
      formEntry("Content") { input(p.content) } 
      formEntry("Created") { input(p.created) }
      formEntry("Public") { input(p.public) }
      formEntry("Comments Allowed") { input(p.commentsAllowed) }
      submit save() { "Save" }
    }
  }
  
access control rules

section comments

  define postComments(p: Post) {
    var url := permalink(p)
    var id := p.id
    if(p.showComments()) {
	    <div id="disqus_thread"></div>
	    <script type="text/javascript">
		    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
		    var disqus_shortname = 'eelcovisser'; // required: replace example with your forum shortname
		
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
    <script type="text/javascript">
	    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
	    var disqus_shortname = 'eelcovisser'; // required: replace example with your forum shortname
	
	    /* * * DON'T EDIT BELOW THIS LINE * * */
	    (function () {
	        var s = document.createElement('script'); s.async = true;
	        s.type = 'text/javascript';
	        s.src = 'http://' + disqus_shortname + '.disqus.com/count.js';
	        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
	    }());
    </script>
  }
  