module user/user-model
 
principal is User with credentials username, password

access control rules 
  rule page *(*) { true }
  rule ajaxtemplate *(*) { true }
  
  predicate isAdministrator() { principal().isAdministrator() }
  predicate isWriter() { principal().mayWrite() }
  predicate isCommenter() { principal().mayComment() }
 
section users

	entity User {
	  username        :: String (id,validate(isUniqueUser(this),"That username is not available"))
	  fullname        :: String (name)
	  password        :: Secret
	  email           :: Email
	  confirmed       :: Bool (default=false)
	  isAdministrator :: Bool (default=false)
	  mayComment      :: Bool (default=true)
	  mayWrite        :: Bool (default=false)
	  
	  function isAdministrator(): Bool {
	    if(isAdministrator == null) { isAdministrator := false; } 
	    return isAdministrator;
	  }
	  function mayComment(): Bool {
      if(mayComment == null) { mayComment := false; }
      return mayComment;
	  }
	  function mayWrite(): Bool {
	    if(mayWrite == null) { mayWrite := false; }
	    return mayWrite;
	  }
	}
	
section registration

  extend entity User {
    confirmEmail -> ConfirmEmail
    function register() {
      username := username.toLowerCase();
      email := email.toLowerCase();
      password := password.digest();
      validate(findUser(username) == null, "That username is not available");
      validate(findUserByEmail(email).length == 0, "That email address is already in use");
      confirmEmail := ConfirmEmail{ user := this email := email };
      if((select count(u) from User as u) == 0) { 
        isAdministrator := true;
        mayWrite := true;
        confirmed := true;
        application.email := email;
      }
      this.save();
      confirmEmail.save();
      email confirmEmail(confirmEmail);
    }
    function update() {
      if(email != confirmEmail.email) {
        confirmEmail := ConfirmEmail{ user := this email := email previous := confirmEmail };
        confirmed := false;
        email confirmEmail(confirmEmail);
      }
    }
  }

  entity ConfirmEmail {
    user      -> User
    email     :: Email
    confirmed :: Bool (default=false)
    created   :: DateTime
    previous  -> ConfirmEmail
    function confirm() { 
      confirmed := true;
      user.confirmed := true;
    }
  }
  
  define email confirmEmail(c: ConfirmEmail) {
    from(application.email)
    to(c.email)
    subject("Confirm your email address")
    "Dear " output(c.user.fullname) ",\n"
    "Thanks for registering for " output(navigate(root())) ".\n"
    "To finalize your registration, please confirm your email address by visiting "
    output(navigate(confirmemail(c))) "\n"
  }