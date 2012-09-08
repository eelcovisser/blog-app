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
  
  entity BlogMenubar : Menubar {
    blog -> Blog
  }
  
  extend entity WikiGroup {  
    menubar    -> Menubar 
    footerMenu -> Menubar
    function menubar(): Menubar {
      return if(menubar != null) menubar else application.menubar();
    }
    function footerMenu(): Menubar {
      return if(footerMenu != null) footerMenu else application.footerMenu();
    }
  }
  
  extend entity Wiki {   
    menubar    -> Menubar 
    footerMenu -> Menubar
    function menubar(): Menubar {
      return if(menubar != null) menubar else group.menubar();
    }
    function footerMenu(): Menubar {
      return if(footerMenu != null) footerMenu else group.footerMenu();
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
  
  function newBlogMenubar(): Menubar {
    var mb := BlogMenubar{ };
    mb.key := mb.id + "";
    mb.save();
    return mb;
  }
  
  entity Menu {
    name     :: String
    items    -> List<MenuItem>
    menubar  -> Menubar (inverse=Menubar.menus)   
    
    function add(item: MenuItem) { items.add(item); }
    function remove(item: MenuItem) { items.remove(item); }
    function addLink() { add(newLink()); }
    function addWiki() { add(newWiki()); }
    function addBlog() { add(newBlog()); }
    
    function up() { up(menubar.menus, this); }
    function down() { down(menubar.menus, this); }    
  }
  
  function newLink(): MenuItem {
    return ExternalLink{ name := "No Title" link := "http://google.com" };
  }
  function newWiki(): MenuItem {
    return WikiLink{ name := "No Title" wiki := findCreateWiki("home","") };
  }
  function newBlog(): MenuItem {
    return BlogLink{ name := "No Title" blog := mainBlog() };
  }
  
  entity MenuItem {
    name :: String
    menu -> Menu (inverse=Menu.items)
    
    function up() { up(menu.items, this); }
    function down() { down(menu.items, this); }   
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
   
section up/down

  function isFirst(xs: List<Menu>, x: Menu): Bool {
    return xs.indexOf(x) > 0;
  }
  
  function isLast(xs: List<Menu>, x: Menu): Bool {
    return xs.indexOf(x) == xs.length - 1;
  }

  function up(xs: List<Menu>, x: Menu) {
    var i := xs.indexOf(x);
    if(xs != null && i > 0) {
      xs.set(i, xs.get(i - 1));
      xs.set(i - 1, x);
    }
  }
  
  function down(xs: List<Menu>, x: Menu) {
    var i := xs.indexOf(x);
    if(xs != null && i < xs.length - 1) {
      xs.set(i, xs.get(i + 1));
      xs.set(i + 1, x);
    }
  }
  
section up/down

  function isFirst(xs: List<MenuItem>, x: MenuItem): Bool {
    return xs.indexOf(x) > 0;
  }
  
  function isLast(xs: List<MenuItem>, x: MenuItem): Bool {
    return xs.indexOf(x) == xs.length - 1;
  }

  function up(xs: List<MenuItem>, x: MenuItem) {
    var i := xs.indexOf(x);
    if(xs != null && i > 0) {
      xs.set(i, xs.get(i - 1));
      xs.set(i - 1, x);
    }
  }
  
  function down(xs: List<MenuItem>, x: MenuItem) {
    var i := xs.indexOf(x);
    if(xs != null && i < xs.length - 1) {
      xs.set(i, xs.get(i + 1));
      xs.set(i + 1, x);
    }
  }
  