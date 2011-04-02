application blog

imports blog/blog-view
imports user/user-view
imports lib/lib 
imports entity/entity

section root page

	define page root(){
	  main{
			list{
			  listitem{ navigate url("http://swerl.tudelft.nl/bin/view/EelcoVisser/WebHome") { "SERG Home Page" } }
			  listitem{ navigate blog(1) { "Blog" } }
			  listitem{ signinoff() }
			  listitem{ navigate initUser() { "init user" } }
		  }
	  }
	}
