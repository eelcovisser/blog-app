module blog/blog-view

imports blog/blog-model
imports layout/layout-view

access control rules
  rule template newBlog() { loggedIn() }

section blog front page

  define page blog() {
    main{ blog(mainBlog()) }
  }
  
  define page other(b: Blog) {
    main{ blog(b) }
  }
  
  define blog(b: Blog) {
    title{ output(b.name) }
    main{
    	<h1>output(b.title)</h1>
      for(p: Post in b.recentPosts(5)) { postInList(p) }
      newPost(b)
    }
  }
  
  define newBlog() {
    var name: String;
    action new() { newBlog(name); return blog(); }
    form{
      input(name)
      submit new() { "Create New Blog" }
    }
  }
  
access control rules

  rule template newPost(b: Blog) { loggedIn() }
  rule ajaxtemplate postEdit(p: Post) { p.mayEdit() }
  
section posts

  define permalink(p: Post) {
    navigate post(p, p.permalink) { elements }
  }

  define newPost(b: Blog) {
    action new() { return post(b.addPost(),""); }
    submitlink new() { "[New Post]" }
  }
  
  define page post(p: Post, title: String) {
    main{
    	placeholder view { postView(p) }
    }
  }
  
  define postInList(p: Post) {
    <h2>permalink(p){ output(p.title) }</h2>
    output(p.content)
  }
    
  define ajax postView(p: Post) {
    action edit() { replace(view, postEdit(p)); }
    <h2>output(p.title)</h2>
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
  
  