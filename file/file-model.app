module file/file-model

section files

  entity Attachments {
    attachments -> Set<Attachment>
    public      :: Bool (default=true)
    
    function add(): Attachment {
      var a := Attachment{ name := "No Name" };
      attachments.add(a);
      return a;
    }
    function public(): Bool { if(public == null) { public := false; } return public; }
    function publish() { public := true; }
    function hide() { public := false; }
    function mayView(): Bool {
      return public || loggedIn();
    }
    function mayEdit(): Bool {
      return loggedIn() && isWriter();
    }
    function remove(a: Attachment) {
      attachments.remove(a);
    }
  }
  
  function newAttachments(): Attachments { 
    return Attachments{};
  }
  
  entity Attachment {
    attachments -> Attachments (inverse=Attachments.attachments)
    name        :: String
    description :: WikiText
    file        :: File
    authors     -> Set<User>
    //created     :: DateTime (default=now())
    //modified    :: DateTime (default=now())
    public      :: Bool (default=true)
    function public(): Bool { return public; }
    function publish() { public := true; }
    function hide() { public := false; }
    function modified() {
      modified := now();
      authors.add(principal());
    }
    function mayView(): Bool {
      return public || loggedIn();
    }
    function mayEdit(): Bool {
      return loggedIn() && isWriter();
    }
  }