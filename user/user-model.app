module user/user-model
 
principal is User with credentials username, password

access control rules 
  rule page *(*) { true }
  rule ajaxtemplate *(*) { true }
 
section users

	entity User {
	  username :: String (id)
	  fullname :: String
	  password :: Secret
	  email    :: Email
	}
	
	function createFirstUser(name: String, pw: Secret) { 
	  var u := User{
	    username := keyFromName(name)
	    fullname := normalizeName(name)
	    password := pw.digest()
	  };
	  u.save();
	}
