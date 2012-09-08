module layout/menu-view

imports layout/menu-model

access control rules

  rule page configmenubar(mb: Menubar, tab: String) {
    isAdministrator()
  }

section display in menubar

  define dropdownMenubar(mb: Menubar) {
  	for(m: Menu in mb.menus) {
  		dropdownMenu(m)
  	}
  	if(mb is a BlogMenubar && (mb as BlogMenubar).blog != null) {
  	  navItem{ navigate index(1,"")  { "Articles" } } // todo: fix
      navItem{ navigate feed("blog") { "Feed"     } } // todo: fix
  	  blogAdminMenu((mb as BlogMenubar).blog)
  	}
  }
  
  template dropdownMenu(m: Menu) {
    if(m.items.length == 0) {      
    } else { if(m.items.length == 1) {
  		navItem{ navMenuItem(m.items[0]) }
  	} else {
  		dropdownInNavbar(m.name){
        dropdownMenu{
        	for(item: MenuItem in m.items) {
        		dropdownMenuItem{ navMenuItem(item) }
        	}
        }
      }
  	} }
  }

  template navMenuItem(item: MenuItem) {
    if(item is a ExternalLink) { navMenuItem(item as ExternalLink) [all attributes] }
    else { if(item is a WikiLink) { navMenuItem(item as WikiLink) [all attributes] } 
    else { if(item is a BlogLink) { navMenuItem(item as BlogLink) [all attributes] } } }
  }
  template navMenuItem(item: ExternalLink) {
  	//navigate url(item.link) [class=attribute("class")] { output(item.name) }
  	<a href=item.link class=attribute("class")> output(item.name) </a>
  }
  template navMenuItem(item: WikiLink) {
    //navigate wiki(item.wiki.key,"") [class=attribute("class")] { output(item.name) }
    nav(item.wiki) [class=attribute("class")] { output(item.name) }
  }
  template navMenuItem(item: BlogLink) {
    if(item.blog.main) {
      navigate blog(0) [class=attribute("class")] { output(item.name) }
    } else {
      navigate other(item.blog,0) [class=attribute("class")] { output(item.name) }
    }
  }
  
section display in footer

  define footerMenubar(mb: Menubar) {
    for(m: Menu in mb.menus) {
      footerMenu(m)
    }
  }
  
  template footerMenu(m: Menu) {
    if(m.items.length == 0) {
      
    } else { if(m.items.length == 1) {
      gridSpan(2){ navMenuItem(m.items[0]) }
    } else {
      gridSpan(2) {
        output(m.name)
        list{
          for(item: MenuItem in m.items) {
            listitem{ navMenuItem(item) }
          }
        }
      }
    } }
  }
  
section configure menubar

  page configmenubar(mb: Menubar, tab: String) {
    define brand() {
      if(mb.brand != null) {
        navMenuItem(mb.brand) [class="brand"]
      } else {
        navigate blog(0) [class="brand"]{ "Menubar Config" }
      }
    }
    mainResponsive{       
      navbarResponsive{
        navItems{
          dropdownMenubar(mb)
        }
      }
      gridContainer{
        messages
        pageHeader{ "Configure Menubar " output(mb.key) }
        editMenubar(mb)
        editMenubars()
        assignMenubars()
      }
      footer{
        gridContainer{
          gridRow{
            footerMenubar(mb)
          }
          pullRight{ signinoff }
        }
      }
    }
  }
  
  template editMenubars() {
    pageHeader{ "All Menubars" }
    tableBordered{    
      for(mb: Menubar) {
        row{ 
          column{ navigate configmenubar(mb, "edit") { output(mb.name) } }
          column{ submitlink action{ mb.delete(); } [class="btn"] { iRemove } }
        }
      }
    }   
    submitlink action{ return configmenubar(newMenubar(),"edit"); } [class="btn"] {
        iPlus "New Menubar"
    } " "
    submitlink action{ return configmenubar(newBlogMenubar(),"edit"); } [class="btn"] {
      iPlus "New Blog Menubar"
    }
  }
  
  template assignMenubars() {
    pageHeader{ "Assign Menubars" }
    form{
    tableBordered{
      row{
        column{ "Page" }
        column{ "Menubar" }
        column{ "Footer" }
      }
      row{
        column{ "Default" }
        column{ input(application.menubar) }
        column{ input(application.footerMenu) }
      }
      for(b: Blog) {
        row{
          column{ "Blog: " navigate other(b,0) { output(b.title) } }
          column{ input(b.menubar) }
          column{ input(b.footerMenu) }
        }
      }
      for(g: WikiGroup order by g.title asc) {       
        row{
          column{ "Wiki Group: " output(g) " (" output(g.keyBase) ")" }
          column{ input(g.menubar) }
          column{ input(g.footerMenu) }
        }
      }
      for(w: Wiki order by w.title asc) {       
        row{
          column{ "Wiki: " output(w) " (" output(w.key) ")" }
          column{ input(w.menubar) }
          column{ input(w.footerMenu) }
        }
      }
    }
    submitlink action{ message("Assignments saved"); } [class="btn btn-primary"] { "Save" }
    }
  }
  
section edit menubar

  template editMenubar(mb: Menubar) {
  	action save() { 
  	  message("Menu changes have been saved"); 
  	  return configmenubar(mb, "");
  	}
    action addMenu() { 
      mb.addMenu();   
      return configmenubar(mb, "");
    }
  	form{
  	  tableBordered{
  	    row{
  	      column{ "Menubar name" } 
  	      column{ input(mb.key) }
  	      column{ "" }
  	    }
  	    row{
  	      column{ "Brand" } 
  	      column{ editBrand(mb) }
  	      column{ "" }
  	    }
  	    if(mb is a BlogMenubar) {
  	      row{
  	        column{ "Blog" }
  	        column{ input((mb as BlogMenubar).blog) }
  	        column{ "" }
  	      }
  	    }
  	    for(m: Menu in mb.menus) {
  		    row{ editMenu(mb, m) }
  		  }
  	  }
      submitlink addMenu() [class="btn"] { "Add Menu" } " "
  	  submitlink save() [class="btn btn-primary"] { "Save" } " "
  	  navigate root() [class="btn"] { "Cancel" } " "
  	}
  }
  
  template editBrand(mb: Menubar) {
    if(mb.brand != null) { 
      editMenuItem(mb.brand) " "
      submitlink action{ mb.brand := null; } [class="btn"] { iRemove }
    } else {
      submitlink action{ mb.brand := newLink(); } [class="btn"] { "Link" }
      submitlink action{ mb.brand := newWiki(); } [class="btn"] { "Wiki" }
      submitlink action{ mb.brand := newBlog(); } [class="btn"] { "Blog" }
    }
  }
  
  template editMenu(mb: Menubar, m: Menu) {
  	column{ 
  	  if(m.items.length > 1) { 
  	    input(m.name) 
  	  } else { if(m.items.length == 1) {
  	    output(m.items[0].name)
  	  } }
  	}
  	column{
  	  editMenuItems(m)
  	}
    column{ 
      submitlink action{ mb.remove(m); } [class="btn"] { iRemove }
      submitlink action{ m.up(); } [class="btn"] { iArrowUp }
      submitlink action{ m.down(); } [class="btn"] { iArrowDown }
    }
  }
  
  template editMenuItems(m: Menu) {
    tableBordered{
      for(item: MenuItem in m.items) {
        row{ 
          column{ editMenuItem(item) }
          column{ 
            submitlink action{ m.remove(item); } [class="btn"] { iRemove }             
            submitlink action{ item.up(); } [class="btn"] { iArrowUp }
            submitlink action{ item.down(); } [class="btn"] { iArrowDown }
          }
        }
      }
      row{
        column{
          submitlink action{ m.addLink(); } [class="btn"] { "Add Link" } " "
          submitlink action{ m.addWiki(); } [class="btn"] { "Add Wiki" } " "
          submitlink action{ m.addBlog(); } [class="btn"] { "Add Blog" } " "
        }
        column{ "" }
      }
    }
  }
  
  template editMenuItem(item: MenuItem) {
  	if(item is a ExternalLink) { editMenuItem(item as ExternalLink) }
  	else { if(item is a WikiLink) { editMenuItem(item as WikiLink) } 
  	else { if(item is a BlogLink) { editMenuItem(item as BlogLink) } } }
  }
  
  template editMenuItem(item: ExternalLink) {
  	input(item.name) " " input(item.link)
  }
  template editMenuItem(item: WikiLink) {
    input(item.name) " " 
    //input(item.wiki)
    select(item.wiki, (select w from Wiki as w order by w.key asc))
  }
  template editMenuItem(item: BlogLink) {
    input(item.name) " " input(item.blog)
  }
  
  
  
