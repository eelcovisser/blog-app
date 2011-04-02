module layout/layout-view

section forms

  define formEntry(l: String){ 
    <div class="entry">
      <span class="label">output(l)</span>
      elements
    </div>
  }

section main template

  define main() {
    includeCSS("eelcovisser.css")
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
        <div id="footer">pagefooter</div>
      </div>
    </div>
  }
  
  define pageheader() {
    <div class="title">
      navigate root(){ "Domain-Specific Language Engineering" } 
    </div>
  }
  
  define copyright() { rawoutput{ "&copyright;" } }
  
  define pagefooter() { 
    "Copyright 2011 Eelco Visser"
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
  
section error messages

  define ignore-access-control templateSuccess(messages : List<String>) {
    <div id="message">
      output(messages)
    </div>
  }
  