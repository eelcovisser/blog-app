module blog/blog-model

imports user/user-model

section blog 

	entity Blog {
		key   :: String (id)
		title :: String (searchable) 
		main  :: Bool (default=false)
		
		about   :: WikiText      
		contact :: WikiText
		links   :: WikiText
		description :: Text // for summaries, RSS
		
		authors -> Set<User>
		
		modified :: DateTime (default=now())
		
		function modified() { 
		  modified := now();
		}
		function rename(x: String) {
		  var k := keyFromName(x);
		  assert(findBlog(k) == null, "that name is already taken");
		  key := k;
		}
		function mayPost(): Bool {
		  return isWriter() && isAuthor();
		}
		function isAuthor(): Bool {
		  return authors.length == 0 || principal() in authors;
		}
	}
	
	function newBlog(name: String): Blog {
	  var b := Blog{ 
	    title := name
	    key   := keyFromName(name)
	  };
	  b.authors.add(principal());
	  if(mainBlogQuery() == null) { b.main := true; }
	  b.save();
	  return b;
	}
	
	function mainBlogQuery(): Blog {
		var bs := select b from Blog as b where b.main = true;
	  if(bs.length > 0) { return bs.get(0); } else { return null; }
	}
	
	function mainBlog(): Blog {
	  var b := mainBlogQuery();
	  if(b == null) { return newBlog("main"); } else { return b; }
	}

section posts

  function showHiddenPosts(): Bool { 
    return loggedIn() && principal().showHiddenPosts();
  }

  extend entity User {
    showHiddenPosts :: Bool (default=true)
    function showHiddenPosts(): Bool {
      if(showHiddenPosts == null) { showHiddenPosts := true; }
      return showHiddenPosts;
    }
    function toggleShowHiddenPosts() { 
      showHiddenPosts := !showHiddenPosts();
    }
  }

  entity LastPost {
  	last :: Int (default=0)
  	function next(): Int { last := last + 1; return last; }
  }
    
  var lastPost := LastPost{}

	extend entity Blog {
	  function recentPosts(index: Int, n: Int, includePrivate: Bool, drafts: Bool): List<Post> {
	    if(drafts) {
	      return select p from Post as p 
                where p.blog = ~this and p.public is false
             order by p.modified desc limit n*(index-1),n;
	    } else { if(includePrivate && showHiddenPosts()) {
		    return select p from Post as p 
		            where p.blog = ~this 
		         order by p.created desc limit n*(index-1),n;
	    } else {
	      return select p from Post as p 
	              where p.blog = ~this and p.public is true
	           order by p.created desc limit n*(index-1),n;
      } }
	  }
	  postCount :: Int (default=0)
	  postPublicCount :: Int (default=0)
	  draftCount :: Int (default=0)
	  function postCount(includePrivate: Bool, drafts: Bool): Int {
	    if(postCount == null) {
	      postCount := (select count(p) from Post as p where p.blog = ~this);
	    }
	    if(postPublicCount == null) {
	      postPublicCount := (select count(p) from Post as p where p.blog = ~this and p.public is true);
	    }
	    if(draftCount == null) {
	      draftCount := (select count(p) from Post as p where p.blog = ~this and p.public is false);
	    }
	    if(drafts) { return draftCount; }
	    if(includePrivate && showHiddenPosts()) { return postCount; } 
	    else { return postPublicCount; }
	  }
	  function addPost(): Post {
	    var p := Post{ 
	    	number  := lastPost.next()
	      blog    := this
	      title   := "No Title"
	    };
	    authors.add(principal());
	    p.save();
	    postCount := null;
	    postPublicCount := null; 
	    return p;
	  }
	}
	
	entity Post {
	  number      :: Int
		key         :: String (id)
		blog        -> Blog
		urlTitle    :: String 
		title       :: String (searchable)
		description :: Text (searchable)
		content     :: WikiText (searchable)
		extended    :: WikiText (searchable)
		public      :: Bool (default=false)
		created     :: DateTime (default=now())
		modified    :: DateTime (default=now())
		deleted     :: Bool (default=false)
		authors     -> Set<User>
		
		function update() {
		  if(extended == null) { extended := ""; }
		  if(description == null) { description := ""; }
		  if(public == null) { public := false; }
		}

		extend function setTitle(x: String) {
		  urlTitle := keyFromName(x);
		}
		extend function setNumber(n: Int) { 
		  key := n + "";
		}
		function modified() {
		  update();
		  var date := now();
		  if(!public) { created := date; }
		  modified := date;
      blog.modified();
		}
		function isAuthor(): Bool {
		  return principal() in authors || blog.isAuthor();
		}
		function mayEdit(): Bool { 
			return isAuthor();
		}
    function mayView(): Bool { 
      update();
      return public || mayEdit();
    }
    function public(): Bool { 
    	update(); return public; 
    }
    function publish() {
    	public := true; 
    	deleted := false;
    	created := now();
    }
    function withdraw() { 
    	public := false; 
    }
    function deleted(): Bool { 
    	if(deleted == null) { deleted := false; } return deleted; 
    }
    function undelete() {
    	deleted := false;
    }
    function remove(): Bool {
    	if(deleted()) {
    		this.delete();
    		return true;
    	} else { 
    		deleted := true;
    	  public := false;
    	  return false;
    	}
    }
	}
	
section comments 

  extend entity Post {
    commentsAllowed :: Bool (default=true)
    function showComments1() {
    	commentsAllowed := true;
    }    
    function hideComments() {
      commentsAllowed := false;
    }
    function publicComments(): Bool {
      if(commentsAllowed == null) { commentsAllowed := true; }
      return public && commentsAllowed;
    }
  }
  
  