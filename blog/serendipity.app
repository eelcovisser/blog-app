module blog/serendipity

imports blog/blog-model

section data model

  entity SerendipityEntry {
  	key           :: Int
  	title         :: String (name)
  	timestamp     :: DateTime
    last_modified :: DateTime
  	body          :: WikiText
  	extended      :: WikiText 
    isdraft       :: Bool
  	converted     :: Bool (default=false)
  	  	
  	function convert(public: Bool): Post { 
  		var p := mainBlog().addPost();
  		p.title := title;
  		p.created := timestamp; 
  		p.modified := last_modified; 
  		p.content := body;
  		p.extended := extended;
  		p.public := public;
  		p.commentsAllowed := false;
  		converted := true;
  		var map :=  LegacyMap{ oldKey := key newKey := p.number };
  		map.save();
  		return p;
  	}
  }
  
  entity LegacyMap {
    oldKey :: Int
    newKey :: Int
  }
  
  // todo: find a way to redirect legacy permalinks 
    
  // example: index.php?/archives/152-Static-Consistency-Checking-of-Web-Applications-with-WebDSL.html
  
  // function legacyPermaLink(url: String): Post {
  //   log("legacyPermaLink(" + url + ")");
  //   var parts := url.split("/");
  //   if(parts.length == 3 && parts.get(0) == "index.php?" && parts.get(1) == "archives") {
  //     var titleParts := parts.get(2).split("-");
  //     var key := titleParts.get(0).parseInt();
  //     if(key != null) {
  //       var maps := from LegacyMap as m where oldKey = key;
  //       if(maps.length > 0) {
  //         var newKey := maps.get(0).newKey;
  //         log("new key = " + newKey);
  //         var post := findPost(newKey.toString());
  //         if(post != null) { return post; }
  //       }
  //     }
  //   }
  //   return null;
  // }
  
  // define page blog(arg1: String, arg2: String, arg3: String) {
  //   var index: Int
  //   init{
  //     log("arg1: " + arg1);
  //     log("arg2: " + arg2);
  //     log("arg3: " + arg3);
  //     index := arg1.parseInt();
  //     if(index == null) { 
  //       var postIndex := legacyPermaLink(arg3);
  //       if(postIndex == null) { 
  //         index := 1; 
  //       } else {
  //         goto post(postIndex,"");
  //       }
  //     }
  //   }
  //   blog(mainBlog(), index)
  // }
  
access control rules

  rule page serendipityIndex() { isAdministrator() }
  rule page serendipityEntry(e: SerendipityEntry) { isAdministrator() }
  
section preview


  // define page serendipityIndex() {
  //   var entries := select e from SerendipityEntry as e;
  //   init{ for(e: SerendipityEntry in entries) { log(e.name); } }
  //   main{
  //     <h2>"Published Posts"</h2> 
  //     list{
  //       for(e: SerendipityEntry in entries where e.isdraft == false && e.converted != true order by e.timestamp asc) {
  //         listitem{ output(e) }
  //       }
  //     }    
  //     <h2>"Draft Posts"</h2> 
  //     list{
  //       for(e: SerendipityEntry in entries where e.isdraft == false && e.converted != true order by e.timestamp asc) {
  //         listitem{ output(e) }
  //       }
  //     }
  //   }
  // }


  define page serendipityIndex() {
  	main{
      <h2>"Published Posts"</h2> 
  		list{
  			for(e: SerendipityEntry where e.isdraft == false && e.converted != true order by e.timestamp asc) {
  				listitem{ output(e) }
  			}
  		}    
  		<h2>"Draft Posts"</h2> 
  		list{
        for(e: SerendipityEntry where e.isdraft == true && e.converted != true order by e.timestamp asc) {
          listitem{ output(e) }
        }
      }
  	}
  }
  
  define page serendipityEntry(e: SerendipityEntry) {
  	action convertPublic() { return post(e.convert(true),""); }
    action convertDraft() { return post(e.convert(false),""); }
   	main{
  		formEntry("Key"){ output(e.key) }
      formEntry("Title"){ output(e.title) }
      formEntry("Timestamp"){ output(e.timestamp) }
      formEntry("Last modified"){ output(e.last_modified) }
      formEntry("Body"){ output(e.body) }
      formEntry("Extended"){ output(e.extended) }
      formEntry("Is Draft"){ output(e.isdraft) }
      formEntry("Converted"){ output(e.converted) }
      submit convertPublic() { "Convert to Public Post" }
      submit convertDraft() { "Convert to Draft" }
  	}
  }
  