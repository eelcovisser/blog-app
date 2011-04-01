module lib/string

  entity StringPair { 
    left :: String
    right :: String
  }

  // does string have no other characters than whitespace?
  function isEmptyString(x : String) : Bool {
    return x == null || (x == "") || /[\n\t\r\ ]+/.replaceAll("", x) == "";
  }
  
  // remove trailing whitespace
  function removeTrailingSpaces(x : String) : String { 
    return /^[\n\t\ ]+/.replaceAll("",/[\n\t\ ]+$/.replaceAll("",x));
  }

  function words(x : String) : List<String> { 
    return /[\t\n\ ]+/.split(removeTrailingSpaces(x)); 
  }
  
  function splitCommaSeparated(x : String) : List<String> {
      return [removeTrailingSpaces(y).toLowerCase() | y : String in x.split(",") where !isEmptyString(y)];
  }
  
  function paragraphs(x : String) : List<String> {
    return /[\n]([\t\ ]*[\n])+/.split(x);
  }
  
  function keyFromName(name : String) : String {
    return (/(\ )+|(\/)+/.replaceAll("-",removeTrailingSpaces(name))).toLowerCase(); 
  }
  
  // replace multiple adjacent whitespace with single space
  // remove trailing whitespace
  function normalizeName(name : String) : String {
    return /[\n\t\ ]+/.replaceAll(" ", removeTrailingSpaces(name));
  }

  function normalizeCiteKey(key : String) : String {
    return makeValidKeyForURL(/[\/+\n\t\ ]+/.replaceAll("-", removeTrailingSpaces(key)));
  }

  function isValidKeyForURL(url : String) : Bool {
    return /[a-zA-Z0-9:\-\.]+/.match(url);
  }

  function makeValidKeyForURL(url : String) : String {
    return /[^a-zA-Z0-9:\-\.]/.replaceAll("", url);
  }

  function prefix(x : String) : String {
    var p : String := "";
    var chars : List<String> := x.split();
    for(i : Int from 0 to chars.length) { p := p + chars.get(i); }
    return p;
  }

  function substring(x : String, i : Int, j : Int) : String {
    var p : String := "";
    var chars : List<String> := x.split();
    for(i : Int from max(0, min(i, chars.length)) to min(j, chars.length)) { p := p + chars.get(i); }
    return p;
  }
  
  function isURL(x : String) : Bool {
    return !isEmptyString(x) && x != "http://" && x != "http:///";
    /* /"http:\/\/\*"/.match(x) && !isEmptyString(/"http:\/\/"/.replaceAll("",x)); */
  }
  
  function isAffiliation(x : String) : Bool {
    return !isEmptyString(x);
  }
  
  function isnull(x : String) : String { 
    if(x == null) { return ""; } else { return x; }
  }
  
  function abbreviate(s : String, length : Int) : String {
    if(s.length() <= length) {
      return s;
    } else {
      return prefix(s, length - 4) + " ...";
    }
  }

  function prefix(s : String, length : Int) : String {
    if(s.length() <= length) {
      return s;
    } else {
      var sChar := s.split();
      sChar.removeAt(length);
      return prefix(sChar.concat(), length);
    }
  }
