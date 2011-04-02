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
    	sidebarSection{ 
    	  <h2>"Recent Posts"</h2>
    	  list{ for(p: Post in b.recentPosts(1,10)){ listitem{ recentPost(p) } } }
    	}
    	blogAdmin(b)
    }
    main{
      elements
    }
  }
  
  define blogAdmin(b: Blog) { 
    sidebarSection{
      newPost(b)  
    }
  }
  
  define link(b: Blog) {
    if(b.main) { navigate blog(1) { elements } } else { navigate other(b,1) { elements } }
  }

section blog front page

  define page blog(index: Int) {
    blog(mainBlog(), index)
  }
  
  define page other(b: Blog, index: Int) {
    blog(b, index) 
  }
  
  define blog(b: Blog,index: Int) {
    title{ output(b.name) }
    bloglayout(b){
      for(p: Post in b.recentPosts(index,5)) { postInList(p) }
    }
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

  rule template newPost(b: Blog) { loggedIn() }
  rule ajaxtemplate postView(p: Post) { 
    true
    rule action edit(){ p.mayEdit() }
  }
  rule ajaxtemplate postEdit(p: Post) { p.mayEdit() }
  
section posts

  define permalink(p: Post) {
    navigate post(p, p.permalink) { elements }
  }
  
  define recentPost(p: Post) {
    permalink(p){ output(p.title) }
  }

  define newPost(b: Blog) {
    action new() { return post(b.addPost(),""); }
    submitlink new() { "[New Post]" }
  }
  
  define page post(p: Post, title: String) {
    bloglayout(p.blog){
    	placeholder view { postView(p) }
    }
  }
  
  define postByLine(p: Post) {
    <div class="postByline">output(p.created.format("MMMM d, yyyy"))</div>
  }
  
  define postInList(p: Post) {
    <div class="postInList">
      <h2>permalink(p){ output(p.title) }</h2>
      postByLine(p)
      <div class="postContent">output(p.content)</div>
    </div>
  }
    
  define ajax postView(p: Post) {
    action edit() { replace(view, postEdit(p)); }
    <h2>output(p.title)</h2>
    postByLine(p)
    output(p.content)
    submitlink edit() { "[Edit]" }
  }
  
  define ajax postEdit(p: Post) {
    action save() { p.modified(); replace(view, postView(p)); }
    form{
      formEntry("Title") { input(p.title) }
      formEntry("Content") { input(p.content) } 
      submit save() { "Save" }
    }
  }
  
  