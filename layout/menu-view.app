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
  }
  
  define dropdownMenu(m: Menu) {
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

  define navMenuItem(item: MenuItem) {
    if(item is a ExternalLink) { navMenuItem(item as ExternalLink) [all attributes] }
    else { if(item is a WikiLink) { navMenuItem(item as WikiLink) [all attributes] } 
    else { if(item is a BlogLink) { navMenuItem(item as BlogLink) [all attributes] } } }
  }
  define navMenuItem(item: ExternalLink) {
  	navigate url(item.link) [all attributes] { output(item.name) }
  }
  define navMenuItem(item: WikiLink) {
    navigate wiki(item.wiki.key,"") [all attributes] { output(item.name) }
  }
  define navMenuItem(item: BlogLink) {
    if(item.blog.main) {
      navigate blog(0) [all attributes] { output(item.name) }
    } else {
      navigate other(item.blog,0) [all attributes] { output(item.name) }
    }
  }
  
section display in footer

  define footerMenubar(mb: Menubar) {
    for(m: Menu in mb.menus) {
      footerMenu(m)
    }
  }
  
  define footerMenu(m: Menu) {
    if(m.items.length == 0) {
      
    } else { if(m.items.length == 1) {
      gridSpan(3){ navMenuItem(m.items[0]) }
    } else {
      gridSpan(3) {
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

  define page configmenubar(mb: Menubar, tab: String) {
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
  
  define editMenubars() {
    pageHeader{ "All Menubars" }
    list{    
      for(mb: Menubar) {
        listitem{ 
          navigate configmenubar(mb, "edit") { output(mb.name) } " "
          submitlink action{ mb.delete(); } [class="btn"] { iRemove }
        }
      }
      listitem{
        submitlink action{ return configmenubar(newMenubar(),"edit"); } [class="btn"] {
          "New Menubar"
        }
      }
    }
  }
  
  define assignMenubars() {
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
          column{ "Blog: " output(b.title) }
          column{ input(b.menubar) }
          column{ input(b.footerMenu) }
        }
      }
      for(w: Wiki order by w.title asc) {       
        row{
          column{ "Wiki: " output(w.title) }
          column{ input(w.menubar) }
          column{ input(w.footerMenu) }
        }
      }
    }
    submitlink action{ message("Assignments saved"); } [class="btn btn-primary"] { "Save" }
    }
  }

  define editMenubar(mb: Menubar) {
  	action save() { message("Menu changes have been saved"); }
  	action addMenu() { mb.addMenu(); }
  	form{
  	  list{
  	    listitem{
  	      "Menubar name: " input(mb.key)
  	    }
  	    listitem{
  	      "Brand: " editMenuItem(mb.brand)
  	    }
  	    for(m: Menu in mb.menus) {
  		    listitem{ editMenu(mb, m) }
  		  }
  	  }
      submitlink addMenu() [class="btn"] { "Add Menu" } " "
  	  submitlink save() [class="btn btn-primary"] { "Save" } " "
  	  navigate root() [class="btn"] { "Cancel" } " "
  	}
  }
  
  define editMenu(mb: Menubar, m: Menu) {
  	input(m.name) " " 
  	submitlink action{ mb.remove(m); } { iRemove }
  	list{
  		for(item: MenuItem in m.items) {
  		  listitem{ 
  		    editMenuItem(item) " "
  		    submitlink action { m.remove(item); } [class="btn"] { iRemove }
  		  }
  		}
  		listitem{
  		  submitlink action{ m.addLink(); } [class="btn"] { "Add Link" } " "
        submitlink action{ m.addWiki(); } [class="btn"] { "Add Wiki" } " "
        submitlink action{ m.addBlog(); } [class="btn"] { "Add Blog" } " "
  		}
  	}
  }
  
  define editMenuItem(item: MenuItem) {
  	if(item is a ExternalLink) { editMenuItem(item as ExternalLink) }
  	else { if(item is a WikiLink) { editMenuItem(item as WikiLink) } 
  	else { if(item is a BlogLink) { editMenuItem(item as BlogLink) } } }
  }
  
  define editMenuItem(item: ExternalLink) {
  	input(item.name) " " input(item.link)
  }
  define editMenuItem(item: WikiLink) {
    input(item.name) " " input(item.wiki)
  }
  define editMenuItem(item: BlogLink) {
    input(item.name) " " input(item.blog)
  }
