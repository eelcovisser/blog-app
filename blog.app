application blog

imports blog/blog-view
imports user/user-view
imports lib/lib 
imports entity/entity
imports wiki/wiki-view

section root page 

  define page root(){
    title { output(application.title) }
    wikilayout() { showWiki("frontpage") }
  }
  
access control rules

  rule page admin() { loggedIn() }
  
section application administration

  entity Application {
    title  :: String
    footer :: WikiText
  }
  
  var application := Application { title := "No Title" footer := "no footer" }
  
  define page admin() {
    main{
      form{
        formEntry("Title"){ input(application.title) }
        formEntry("Footer"){ input(application.footer) }
        submit action{ } { "Save" }
      }
    }
  }
  