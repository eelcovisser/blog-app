module lib/math

  function abs(i : Int) : Int {
    if(i < 0) { return 0 - i; } else { return i; }
  }
  
  function max(i : Int, j : Int) : Int {
    if(i > j) { return i; } else { return j; }
  }
  
  function min(i : Int, j : Int) : Int {
    if(i > j) { return j; } else { return i; }
  }
  
  function mod(i : Int, j : Int) : Int {
    return i - (j * (i / j));
  }
