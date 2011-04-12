module user/user-model 
 
principal is User with credentials username, password

access control rules 
  rule page *(*) { true }
  rule ajaxtemplate *(*) { true }
  
  predicate isAdministrator() { loggedIn() && principal().isAdministrator() }
  predicate isWriter() { loggedIn() && principal().mayWrite() }
  predicate isCommenter() { loggedIn() && principal().mayComment() }
 
section users

	entity User {
	  username        :: String (id,validate(isUniqueUser(this),"That username is not available"))
	  fullname        :: String (name)
	  password        :: Secret
	  email           :: Email
	  profile         :: WikiText
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
	  function mayUpdate(): Bool {
	    return loggedIn() 
	        && (principal() == this || principal().isAdministrator());
	  }
	}
	
section reset password

  extend entity User {
    function savePassword() { 
      password := password.digest();
    }
    function resetPassword() {
      var r := ResetPassword{ user := this };
      r.save();
      email resetPassword(r);
    }
  }
  
  entity ResetPassword {
    user    -> User
    created :: DateTime (default=now())
  }
  
  define email resetPassword(r: ResetPassword) {
    to(r.user.email)
    from(application.email)
    subject("Reset Password")
    "You can reset your password for " output(navigate(root())) " by visiting " 
    output(navigate(reset(r)))
  }
	
section registration

  extend entity User {
    confirmEmail -> ConfirmEmail
    function register() {
      log("register");
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
        application.acceptRegistrations := false;
      } 
      this.save();
      confirmEmail.save();
      log("register done; sending email");
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
    par{"Dear " output(c.user.fullname) ","}
    par{ "Thanks for registering for " output(navigate(root())) "."}
    par{ "To finalize your registration, please confirm your email address by visiting "
         output(navigate(confirmemail(c))) }
  }