module layout/layout-view

section main template

  define main() {
    includeCSS("eelcovisser.css")
    includeHead(rendertemplate(rssLink()))
    analytics()
    <div id="pageheader">
      <div id="pageheadercontent">
        pageheader
      </div>
    </div>
    <div id="outercontainer">
      <div id="container">
        <div id="sidebar">sidebar</div>
        <div id="contents">messages elements</div>
        <div class="clear"> </div>
      </div>
      <div class="clear"> </div>
    </div>
    <div id="footercontainer">
      <div id="footercontent">
        <div id="footer">signinoff pagefooter</div>
      </div>
    </div>
  }
  
  define pageheader() {
    <div class="title">
      navigate root(){ output(application.title) } 
    </div>
  }
  
  define copyright() { rawoutput{ "&copyright;" } }
  
  define pagefooter() { 
    output(application.footer)
  }
  
  define sidebar() {
    //showWiki("sidebar")
    // if(loggedIn()){
    //   showWiki("admin-sidebar")
    // }
  }
  
  define sidebarSection(){
    <div class="sidebarSection">
      elements
    </div>
  }
  
  define rssLink() { }
  
section error messages

  define override ignore-access-control templateSuccess(messages : List<String>) {
    <div id="message">
      output(messages)
    </div>
  }
  
section tracking

  // 

  define analytics() {
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
  