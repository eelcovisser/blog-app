module entity/entity

section dispatch functions on Entity
 
  function mayView(e : Entity) : Bool {
    if(e is a Wiki)     { return (e as Wiki).mayView(); }
    return false;
  }  
  function mayEdit(e : Entity) : Bool {
    if(e is a Wiki)     { return (e as Wiki).mayEdit(); }
    return false;
  }
  function modified(e : Entity) {  
    log("modified");
    if(e is a Wiki)     { (e as Wiki).modified(); }
  }