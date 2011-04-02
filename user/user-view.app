module user/user-view

imports user/user-model

section user profile

  define output(u: User) {
    output(u.fullname)
  }

	define page user(u: User) {
	  main{
	    output(u.fullname)
	  }
	}

section the first user

	define page initUser() {  
	  init{ if((select u from User as u).length > 0) { return root(); } }
	  var name: String
	  var pw1: Secret
	  var pw2: Secret
	  form{
	    formEntry("Name"){ input(name) }
	    formEntry("Password"){ input(pw1) }
	    formEntry("Repeat Password"){ 
	      input(pw2){ validate(pw1 == pw2, "passwords don't match")} 
	    }
	    submit action{ createFirstUser(name, pw1); } { "Go" }
	  }
	}

section authentication

  define page login() {
    main{
      signinoff
    }
  }

	define signinoff() {
		if(loggedIn()) { signoff() } else { signin() }
	}
	define signin() {
		var n: String
		var p: Secret
		form{
			input(n) input(p)
			submit action{ authenticate(n, p); } { "Sign In" }
		}
	}
	define signoff() {
		form{ submit action{ logout(); }{ "Sign Off" } }
	}