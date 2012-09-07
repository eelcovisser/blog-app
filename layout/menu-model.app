module layout/menu-model

section application menus

  extend entity Application {
    menubar    -> Menubar (default=Menubar{ key := "menubar" })
    footerMenu -> Menubar (default=Menubar{ key := "footermenu" })
    
    function menubar() : Menubar {
      if(menubar == null) { 
        menubar := Menubar{ key := "menubar" }; 
      }
      return menubar;
    }
    function footerMenu() : Menubar {
      if(footerMenu == null) { 
        footerMenu := Menubar{ key := "footermenu" }; 
      }
      return footerMenu;
    }
  }
  
  extend entity Blog {   
    menubar    -> Menubar 
    footerMenu -> Menubar
    function menubar(): Menubar {
      if(menubar == null) {
        return application.menubar();
      } else {
        return menubar;
      }
    }
    function footerMenu(): Menubar {
      if(footerMenu == null) {
        return application.footerMenu();
      } else {
        return footerMenu;
      }
    }
  }
  
  extend entity Wiki {   
    menubar    -> Menubar 
    footerMenu -> Menubar
    function menubar(): Menubar {
      if(menubar == null) {
        return application.menubar();
      } else {
        return menubar;
      }
    }
    function footerMenu(): Menubar {
      if(footerMenu == null) {
        return application.footerMenu();
      } else {
        return footerMenu;
      }
    }
  }

section menu

  entity Menubar { 
    key   :: String (id)
    name  :: String := if(key == null || key == "") "anonymous" else key
    menus -> List<Menu>
    brand -> MenuItem
    
    function addMenu() { 
      var m := Menu{ name := "No Title" };
      menus.add(m);
    }
    function remove(m: Menu) {
      menus.remove(m);
    }
  }
  
  function newMenubar(): Menubar { 
    var mb := Menubar{ };
    mb.key := mb.id + "";
    mb.save();
    return mb;
  }
  
  entity Menu {
    name      :: String
    items -> List<MenuItem>
    function addLink() {
    	items.add(ExternalLink{ name := "No Title" link := "http://google.com" });
    }
    function addWiki() {
      items.add(WikiLink{ name := "No Title" wiki := findCreateWiki("frontpage") });
    }
    function addBlog() {
      items.add(BlogLink{ name := "No Title" blog := mainBlog() });
    }
    function remove(item: MenuItem) {
      items.remove(item);
    }
  }
  
  entity MenuItem {
    name :: String
  }
  
  entity ExternalLink : MenuItem {
    link :: URL
  }
  
  entity WikiLink : MenuItem {
    wiki -> Wiki
  }
  
  entity BlogLink : MenuItem {
  	blog -> Blog
  }
   
  
  