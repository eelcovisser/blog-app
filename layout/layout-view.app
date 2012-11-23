module layout/layout-view

imports layout/menu-view

section web fonts

  define bitterfont() {
    <link href="http://fonts.googleapis.com/css?family=Bitter" rel="stylesheet" type="text/css" />
  }

section main template

  define mainStatic() {    
    includeCSS("bootstrap-extension.css")
    includeCSS("bootstrap/css/bootstrap.css")  
    includeCSS("bootstrap/css/bootstrap-adapt.css")
    includeJS("jquery.js")
    includeJS("bootstrap/js/bootstrap.js")
    includeHead("<meta name='viewport' content='width=device-width, initial-scale=1.0'>") 
    elements
  }
  
  define mainResponsive() {    
    includeCSS("bootstrap/css/bootstrap.css") 
    includeCSS("bootstrap/css/bootstrap-responsive.css")   
    includeCSS("bootstrap/css/bootstrap-adapt.css")
    includeCSS("bootstrap-extension.css")
    includeJS("jquery.js")
    includeJS("bootstrap/js/bootstrap.js")
    includeHead("<meta name='viewport' content='width=device-width, initial-scale=1.0'>")   
    //includeHead(rendertemplate(rssLink()))
    includeHead(rendertemplate(analytics))
    //includeHead(rendertemplate(bitterfont))
    //<link href="http://fonts.googleapis.com/css?family=Bitter" rel="stylesheet" type="text/css">
    elements
  }

  define main() { 
    mainResponsive{ 
      navbar(application.menubar())
      gridContainer{
        messages
        elements 
      }
      footer(application.footerMenu())
    }
  }
  
  define brand() { 
    navigate root() [class="brand"]{ "Blog" }
  }
  
  define navigationbar() {    
    navbar{
      brand()
      navItems{
        elements
      }
    }
  }
  
  define navbar(menubar: Menubar) {
    define brand() {
      if(menubar.brand != null) {
        navMenuItem(menubar.brand) [class="brand"] 
      } 
    }
    navbarResponsive{
      navItems{ 
        dropdownMenubar(menubar)
        elements
      }
    }
  }
  
  define footer(menubar: Menubar) {
      footer{
        gridContainer{     
          gridRow{ footerMenubar(menubar) }
          gridRow{
            gridSpan(8) { pagefooter }
            gridSpan(4) { pullRight{ signinoff } }
          }
        }
      }
  }

section old main

  // define mainOld() {
  //   // http://www.google.com/webfonts
  //   // sans serif
  //   includeCSS("http://fonts.googleapis.com/css?family=Cabin+Sketch:bold")
  //   // monospace
  //   includeCSS("http://fonts.googleapis.com/css?family=Droid+Sans+Mono")
  //   // sans serif
  //   includeCSS("http://fonts.googleapis.com/css?family=Cabin")
  //   
  //   // sans serif
  //   // includeCSS("http://fonts.googleapis.com/css?family=Expletus+Sans")
  //   
  //   // serif
  //   // includeCSS("http://fonts.googleapis.com/css?family=Philosopher")
  //   
  //   // typewriter
  //   // includeCSS("http://fonts.googleapis.com/css?family=Special+Elite")
  //   // includeCSS("http://fonts.googleapis.com/css?family=Anonymous+Pro")
  //   
  //   // script
  //   //includeCSS("http://fonts.googleapis.com/css?family=Walter+Turncoat")
  //   
  //   includeCSS("style.css")
  //   includeHead(rendertemplate(rssLink()))
  //   includeHead(rendertemplate(analytics))
  //   <div id="pageheader">
  //     <div id="pageheadercontent">
  //       //pageheader
  //     </div>
  //   </div>
  //   <div id="outercontainer">
  //     <div id="container">
  //       <div id="sidebar">sidebar</div>
  //       <div id="contents">messages elements</div>
  //       <div class="clear"> </div>
  //     </div>
  //     <div class="clear"> </div>
  //   </div>
  //   <div id="footercontainer">
  //     <div id="footercontent">
  //       <div id="footer">signinoff pagefooter</div>
  //     </div>
  //   </div>
  // }
  
  define clear() { 
    <div class="clear" />
  }
  
  // define pageheader() {
  //   <div class="title">
  //     navigate root(){ output(application.title) } 
  //   </div>
  // }
  
  define copyright() { rawoutput{ "&copyright;" } }
  
  define pagefooter() { 
    output(application.footer)
  }
  
  // define sidebar() {
  //   showWiki("sidebar")
  //   if(loggedIn()){
  //     showWiki("admin-sidebar")
  //   }
  // }
  
  define sidebarSection(){
    <div class="sidebarSection">
      elements
    </div>
  }
  
  define rssLink() { }
  
section error messages

  // define override ignore-access-control templateSuccess(messages : List<String>) {
  //   <div id="message">
  //     output(messages)
  //   </div> 
  // }
  
section tracking

  template analytics() {
    var account := application.analyticsAccount
    if(application.analyticsOn != null && application.analyticsOn) {
	    <script type="text/javascript">
	      var _gaq = _gaq || [];
	      _gaq.push(['_setAccount', '~account']);
	      _gaq.push(['_trackPageview']);
	      (function() {
	        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	      })();
	    </script>
    }
  }
  
