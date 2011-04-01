module entity/entity

section dispatch functions on Entity

  function mayView(e : Entity) : Bool {
    // if(e is a Reaction)     { return (e as Reaction).mayView(); }
    // if(e is a Discussion)   { return (e as Discussion).mayView(); }
    // if(e is a UserIdentity) { return (e as UserIdentity).mayView(); }
    return false;
  }  
  function mayEdit(e : Entity) : Bool {
    // if(e is a Reaction)     { return (e as Reaction).mayEdit(); }
    // if(e is a Discussion)   { return (e as Discussion).mayEdit(); }
    // if(e is a UserIdentity) { return (e as UserIdentity).mayEdit(); }
    return false;
  }
  function modified(e : Entity) {  
    // if(e is a Reaction)     { (e as Reaction).modified(); }
    // if(e is a Discussion)   { (e as Discussion).modified(); }
    // if(e is a UserIdentity) { (e as UserIdentity).modified(); }
  }
 