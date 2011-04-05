module user/user-view

imports user/user-model

section user profile

  define output(u: User) {
    navigate profile(u){ output(u.fullname) }
  }
 
	define page profile(u: User) {
	  define sidebar() {
	    navigate updateaccount(u) { "Update Account" }
	  }
	  main{
	    <h1>output(u.fullname)</h2>
	    //contributions
	  }
	}
	
section authentication

	define signinoff() {
		<div class="signinoff">
		  if(loggedIn()) { signoff() } else { signin() }
		</div>
	}
	define signin() {
		var n: String
		var p: Secret
		form{
			input(n) input(p)
			submit action{ authenticate(n, p); } { "Sign In" }
		}
		" | " navigate register() { "Sign Up" }
		" | " navigate resetpassword(){ "Reset Password" }
	}
	define signoff() {
		"Signed as " output(principal()) " | " form{ submitlink action{ logout(); }{ "[Sign Off]" } }
	}

section access denied

  define page accessDenied() {
    init{ 
      message("That page does not exist, or you don't have permission to access it.");
      return root();
    }
  }
  
access control rules

  rule page updateaccount(u: User) {
    principal() == u
  }
  
section update account 

  define page updateaccount(u: User) {
    action save() { u.update(); }
    main{
      <h1>"Update Account"</h1>
      form{
        editUser(u)
        submit save() { "Update" }
      }
      <h1>"Reset Password"</h1>
      form{
        editPassword(u)
        submit save() { "Reset" }
      }      
    }
  }
  
  define editUser(u: User) {
    formEntry("Username" ){ input(u.username) {
      validate(findUser(u.username) == null, "That username is not available")
    }}
    formEntry("Full name"){ input(u.fullname) }
    formEntry("Email"    ){ input(u.email) {
      validate(findUserByEmail(u.email).length == 0, "That email address is already in use")
    } }
  }
  
  define editPassword(u: User){ 
    var p : Secret
    formEntry("Password" ){ input(u.password) }
    formEntry("Repeat Password" ){ input(p) { 
      validate(p == u.password, "passwords don't match")}
    } 
  }
  
section reset password

  define page resetpassword() {
    init{ if(loggedIn()) { goto updateaccount(principal()); } }
    // todo
  }
  
section registration

  define page register() {
    var u := User{}
    action register() { 
      u.register();
      message("Thanks for registering; we will send you an email to confirm your email adress.");
      return root();
    }
    title{ "Registration" }
    main{
      <h1>"Registration"</h1>
      form{
        editUser(u)
        editPassword(u)
        captcha
        submit register() { "Register"}
      }
    }
  }
  
  define page confirmemail(c: ConfirmEmail) {
    init{ 
      c.confirm();
      message("Thanks for confirming your email address.");
      return root();
    }
  }
  