module user/user-view

imports user/user-model

access control rules

  rule page editprofile(u: User) { u.mayUpdate() }
  rule page signin() { true }
  
section user profile

  template output(u: User) {
    navigate profile(u){ output(u.fullname) }
  }
 
	page profile(u: User) {
	  init{ 
	    //return root();
	    // if(u.profileLink != null) { 
	    //   return wiki(u.profileWiki.group.keyBase, u.profileWiki.keyBase, "");
	    // }
	  }
	  main{
	    pageHeader{ output(u.fullname) }
	    output(u.profile)
	    //contributions
	    navigate editprofile(u) [class="btn"] { iPencil " Edit" } " "
	    navigate updateaccount(u) [class="btn"] { "Update Account" }
	  }
	}
	
	page editprofile(u: User) {
	  main{
      pageHeader{ output(u.fullname) }
      horizontalForm{
        controlGroup("Profile") { input(u.profile) }
        // controlGroup("Redirect") { 
        //   editMenuItem(u.profileLink)
        // }
        formActions{
          submitlink action{ return profile(u); } [class="btn btn-primary"] { "Save" }
        }
      }
	  }
	}
	
section authentication

	template signinoff() {
		<div class="signinoff">
		  if(loggedIn()) { signoff() } else { navigate signin() { "Sign In" } }
		</div>
	}
	
	page signin() {
    var n: String
    var p: Secret
	  action auth() { 
	    // var u := findUser("eelcovisser");
	    // if(u != null) { 
	    //   securityContext.principal := u;
	    // }
	    authenticate(n, p); 
	  }
	  title{ "sign in" }
	  main{
	    gridRow{
	      gridSpan(8){
	        pageHeader{ "Sign In" }
		      horizontalForm{
			      controlGroup("User Name") { input(n) }
		  	    controlGroup("Password") { input(p) }
		  	    formActions{
			        submit auth() [class="btn btn-primary"] { "Sign In" } " "
			        navigate register() [class="btn"] { "Sign Up" } " "
              navigate resetpassword() [class="btn"] { "Reset Password" }
            }
          }
		    }
		  }
		}
	}
	
	template signoff() {
		"Signed as " output(principal()) " | " 
		submitlink action{ logout(); } [class="btn"] { "Sign Off" }
	}

section access denied

  template override page accessDenied() {
    init{ 
      message("That page does not exist, or you don't have permission to access it.");
      return root();
    }
  }
  
access control rules

  rule page updateaccount(u: User) { u.mayUpdate() }
  
  rule template authorizeUser(u: User) {
    principal().isAdministrator()
  }
  
section update account 

  page updateaccount(u: User) {
    action save() { u.update(); }
    main{
      pageHeader{ "Update Account" }
      horizontalForm{
        editUser(u)
        formActions{ submit save() [class="btn btn-primary"] { "Update" } }
      }
      pageHeader{ "Reset Password" }
      horizontalForm{
        editPassword(u)
        formActions{ submit save() [class="btn btn-primary"] { "Reset" } }
      }
      authorizeUser(u)
    }
  }
  
  template editUser(u: User) {
    formEntry("Username" ){ input(u.username) {
      validate(findUser(u.username) == null, "That username is not available")
    }}
    controlGroup("Full name"){ input(u.fullname) }
    controlGroup("Email"    ){ input(u.email) {
      validate(findUserByEmail(u.email).length == 0, "That email address is already in use")
    } }
  }
  
  template editPassword(u: User){ 
    var p : Secret
    controlGroup("Password" ){ input(u.password) }
    controlGroup("Repeat Password" ){ input(p) { 
      validate(p == u.password, "passwords don't match")}
    } 
  }
  
  template authorizeUser(u: User) {
    action authorize() { return profile(u); }
    pageHeader{ "Authorize User" }
    horizontalForm{
      controlGroup("May Comment"){
        input(u.mayComment)
      }
      controlGroup("May Write"){
        input(u.mayWrite)
      }
      controlGroup("Is Administrator"){
        input(u.isAdministrator)
      }
      formActions{
        submitlink authorize() [class="btn btn-primary"] { "Authorize" }
      }
    }
  }
  
section reset password

  page resetpassword() {
    init{ if(loggedIn()) { goto updateaccount(principal()); } }
    var email: Email
    action reset() { 
      var users := findUserByEmail(email);
      validate(users.length == 1, "That email address is unknown to us.");
      users.get(0).resetPassword();
      message("You will receive instructions for resetting your password by email.");
      return root();
    }
    title{"Reset Password"}
    main{
      gridRow{
        gridSpan(8){
          pageHeader{ "Reset Password"}
          horizontalForm{
            controlGroup("Email"){ input(email) }
            controlGroup("Are you human?"){ captcha }
            formActions{
              submit reset() [class="btn"] { "Reset" } " "
              navigate root() [class="btn"] { "Cancel" }
            }
          }
        }
      }
    }
  }
  
  page reset(r: ResetPassword) {
    action save() { 
      r.user.savePassword();
      message("Your password has been reset.");
      return root();
    }    
    title{"Set New Password"}
    main{
      pageHeader{ "Enter New Password" }
      horizontalForm{
        editPassword(r.user)
        formActions{
          submitlink save() [class="btn btn-primary"] { "Save" }
        }
      }
    }
  }
  
access control rules
  
  rule page register() {
    application.acceptRegistrations || isAdministrator()
  }
  
section registration

  page register() {
    var u := User{}
    action register() { 
      u.register();
      message("Thanks for registering; we will send you an email to confirm your email adress.");
      return root();
    }
    title{ "Registration" }
    main{
      pageHeader{ "Registration" }
      horizontalForm{
        editUser(u)
        editPassword(u)
        captcha
        formActions{
          submitlink register() [class="btn btn-primary"] { "Register"}
        }
      }
    }
  }
  
  page confirmemail(c: ConfirmEmail) {
    init{ 
      c.confirm();
      message("Thanks for confirming your email address.");
      return root();
    }
  }
  