module gallery/gallery-view

imports gallery/gallery-model

access control rules
  rule page gallery() { true }
  rule template addPhoto() { loggedIn() }
  
  rule page photo(photo: Photo) { photo.mayView() }
  //rule page photodownload(photo: Photo) { true } 

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
  	init{ photo.init(); }
    navigate photo(photo){ output(photo.thumbnail)[style="width:150px"] }
  }
  
  define addPhoto() {
    var photo := Photo{}
    action add() { 
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
    action delete() { photo.delete(); return gallery(); }
    action resize() { photo.resize(); }
     var o := rendertemplate(photoImageUrlOriginal(photo)).split("src='")[1].split("' ></img>")[0]
     var l := rendertemplate(photoImageUrlLarge(photo)).split("src='")[1].split("' ></img>")[0]
     var m := rendertemplate(photoImageUrlMedium(photo)).split("src='")[1].split("' ></img>")[0]
     var s := rendertemplate(photoImageUrlSmall(photo)).split("src='")[1].split("' ></img>")[0]
     var t := rendertemplate(photoImageUrlThumbnail(photo)).split("src='")[1].split("' ></img>")[0]
  	 main{
  		header{ output(photo.title) }
  		output(photo.medium)
  		output(photo.description)
      navigate url(t) { "[thumbnail]" }
      navigate url(s) { "[small]" }
      navigate url(m) { "[medium]" }
      navigate url(l) { "[large]" }
      navigate url(o) { "[original]" }
  		submitlink resize() { "[Resize]" }
  		submitlink delete() { "[Delete]" }
  		navigate photoFullscreen(photo, "o", photo.filename()) { "[fullscreen]" }
  	}      
  } 
  
  define page photoFullscreen(photo: Photo, size: String, filename: String) {
    mimetype("image/jpg")
    init{ 
      case(size) { 
        "m" { photo.original.download(); }
      }
    }
  }
  
  define photoImageUrlOriginal(photo: Photo) { output(photo.original) }
  define photoImageUrlLarge(photo: Photo) { output(photo.large) }
  define photoImageUrlMedium(photo: Photo) { output(photo.medium) }  
  define photoImageUrlSmall(photo: Photo) { output(photo.small) }
  define photoImageUrlThumbnail(photo: Photo) { output(photo.thumbnail)  }
  
  // define page photodownload(photo: Photo) {
  //   init{
  //     return photo.url("");
  //   }
  // }
 
  // photo download: see workaround at http://yellowgrass.org/issue/WebDSL/367
  
  /* 
    entity Test{
    img :: Image
  }

  var t:=Test{}

  define page root(){
    var s := rendertemplate(test()).split("src='")[1].split("' ></img>")[0]
    form{
        input(t.img)
        submit action{  } {"save"}

    }
    output(t.img)
    test()  
    output(s)
  }

  define test(){
    output(t.img)
  }
  
  */