module blog/blog-service

imports blog/blog-model

section blog

  extend entity Blog { 
    function json():  JSONObject {
      var obj := JSONObject();
      obj.put("id", id);
      obj.put("title", title);
      obj.put("about", about);
      obj.put("description", description);
      obj.put("modified", modified);
      return obj;
    }
  }

  service apiblog() {
    return mainBlog().json();
  }
  
section post

  extend entity Post {
    function json(): JSONObject {
      var obj := JSONObject();
      obj.put("id", id);
      obj.put("number", number);
      obj.put("key", key);
      obj.put("urlTitle", urlTitle);
      obj.put("title", title);
      obj.put("description", description);
      obj.put("content", content);
      obj.put("extended", extended);
      obj.put("created", created);
      obj.put("modified", modified);
      //obj.put("", );
      //obj.put("", );
      return obj;
    }
  }
  
  function json(posts: List<Post>): JSONArray {
    var array := JSONArray();
    for(p: Post in posts) { array.put(p.json()); }
    return array;
  }
  
  service apirecentposts() {
    return json(mainBlog().recentPublicPosts(0, 5));
  }
  
  service apipost(p: Post) {
    return p.json();
  }