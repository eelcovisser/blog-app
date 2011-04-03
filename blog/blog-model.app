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
		
		function rename(x: String) {
		  var k := keyFromName(x);
		  assert(findBlog(k) == null, "that name is already taken");
		  key := k;
		}
	}
	
	function newBlog(name: String): Blog {
	  var b := Blog{ 
	    title := name
	    key   := keyFromName(name)
	  };
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

  entity LastPost {
  	last :: Int (default=0)
  	function next(): Int { last := last + 1; return last; }
  }
    
  var lastPost := LastPost{}

	extend entity Blog {
	  function recentPosts(index: Int, n: Int, includePrivate: Bool): List<Post> {
	    if(includePrivate) {
		    return select p from Post as p 
		            where p.blog = ~this 
		         order by p.created desc limit n*(index-1),n;
	    } else {
	      return select p from Post as p 
	              where p.blog = ~this and p.public is true
	           order by p.created desc limit n*(index-1),n;
      }
	  }
	  postCount :: Int (default=0)
	  postPublicCount :: Int (default=0)
	  function postCount(includePrivate: Bool): Int {
	    if(postCount == null) {
	      postCount := (select count(p) from Post as p where p.blog = ~this);
	    }
	    if(postPublicCount == null) {
	      postPublicCount := (select count(p) from Post as p where p.blog = ~this and p.public is true);
	    }
	    if(includePrivate) { return postCount; } else { return postPublicCount; }
	  }
	  function addPost(): Post {
	    var p := Post{ 
	    	number  := lastPost.next()
	      blog    := this
	      title   := "No Title"
	      author  := principal()
	    };
	    p.save();
	    postCount := null;
	    postPublicCount := null;
	    return p;
	  }
	}
	
	entity Post {
	  number    :: Int
		key       :: String (id)
		blog      -> Blog
		urlTitle  :: String 
		title     :: String (searchable)
		content   :: WikiText (searchable)
		public    :: Bool (default=false)
		created   :: DateTime (default=now())
		modified  :: DateTime (default=now())
		author    -> User
		    
		extend function setTitle(x: String) {
		  urlTitle := keyFromName(x);
		}
		extend function setNumber(n: Int) { 
		  key := n + "";
		}
		function modified() {
		  modified := now();
		}
		function mayEdit(): Bool { 
			return author == principal();
		}
    function mayView(): Bool { 
      if(public == null) { public := false; }
      return public || mayEdit();
    }
	}
