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

  service apiPost(p: Post) {
    
  }