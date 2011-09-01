module gallery/gallery-view

imports gallery/gallery-model

access control rules
  rule page gallery() { true }
  rule page photo(photo: Photo) { true }
  rule template addPhoto() { loggedIn() } 

section gallery

  define page gallery() {
    main{
      for(photo: Photo order by photo.created desc) {
        thumbnail(photo)
      }
      addPhoto()
    }
  }
   
  define thumbnail(photo: Photo) {
  	init{ 
  		if(photo.thumbnail == null) { 
  			photo.delete(); 
  			goto gallery();
  	  } 
  	}
    navigate photo(photo){ output(photo.thumbnail)[style="width:150px"] }
  }
  
  define addPhoto() {
    var photo := Photo{}
    action add() { 
    	photo.add();
    	photo.save();
    	return photo(photo);
    }
    form{
      formEntry("Photo"){ input(photo.original) }
      formEntry("Title"){ input(photo.title) }
      formEntry("Description"){ input(photo.description) }
      submit add() { "Save" }
    }
  }
  
section photo page
  
  define page photo(photo: Photo) {
  	main{
  		header{ output(photo.title) }
  		output(photo.normal)[style="width:600px"]
  		output(photo.description)
  		// delete photo
  	}
  }
  
  define page photoFullscreen(photo: Photo) {
  	output(photo.original)
  }