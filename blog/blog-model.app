module blog/blog-model

imports user/user-model
 
entity Blog {
	name  :: String
	key   :: String (id)
	title :: String
	main  :: Bool (default=false)
	
	function rename(x: String) {
	  var k := keyFromName(x);
	  assert(findBlog(k) == null, "that name is already taken");
	  name := x;
	  key := key;
	}
}

function newBlog(name: String): Blog {
  var b := Blog{ 
    name  := name
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

	extend entity Blog {
	  last :: Int (default=0)
	  function recentPosts(index: Int, n: Int): List<Post> {
	    return select p from Post as p where p.blog = ~this order by p.created desc limit n*(index-1),n;
	  }
	  function addPost(): Post {
	    last := last + 1;
	    var p := Post{ 
	    blog  := this
	    title := "No Title"
	    permalink := key + last
	    author := principal()
	  };
	  p.save();
	  return p;
	  }  
	}
	
	entity Post {
	  number    :: Int
		permalink :: String (id)
		blog      -> Blog
		key       :: String 
		title     :: String
		content   :: WikiText
		created   :: DateTime (default=now())
		modified  :: DateTime (default=now())
		author    -> User
		    
		extend function setTitle(x: String) {
		  key := keyFromName(x);
		}
		extend function setNumber(n: Int) { 
		  
		}
		function modified() {
		  modified := now();
		}
		function mayEdit(): Bool { 
			return author == principal();
		}
	}

