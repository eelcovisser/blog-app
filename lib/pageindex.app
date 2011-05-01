module lib/pageindex

  define span pageIndexLink(i : Int, lab : String) { 
    "no definition of pageIndexLink" 
  }
  
  define pageIndex(index : Int, count : Int, perpage : Int) {
    var idx := max(1,index)
    var pages : Int := 1 + count/perpage
    container[class="pageIndex"] {
	    if(pages > 1) { 
	      if(idx > 1) { 
	        container[class="indexEntryActive"]{ pageIndexLink(idx-1, "Previous") }
	      } else { 
	        container[class="indexEntryInactive"]{ "Previous" }
	      }
	      for(i : Int from 1 to pages+1) {  
	        if(i == idx) {
	          container[class="indexEntryCurrent"]{ output(i) }
	        } else { 
	          container[class="indexEntryActive"]{ pageIndexLink(i, i + "") }
	        }
	      }
	      if(idx < pages) { 
	        container[class="indexEntryActive"]{ pageIndexLink(idx+1,"Next") }
	      } else { 
	        container[class="indexEntryInactive"]{ "Next" }
	      }
	    }
    }
  }
    
  function showIndex(i: Int, idx: Int, pages: Int, max: Int, middle: Int, end: Int): Bool {    
    if(pages <= max) {
      return true;
    } else { if(idx <= end + 1 + middle) {
      return i <= end + 1 + 2 * middle 
           || i > pages - end;
    } else { if(idx >= pages - end + 1 - middle) { 
      return i >= pages - end + 1 - 2 * middle
          || i <= end;
    } else { 
      return i <= end 
          || i > pages - end
          || (i > idx - middle && i <= idx + middle);
    } } }
  }
  
  function showGap(i: Int, idx: Int, pages: Int, max: Int, middle: Int, end: Int): Bool {
    return pages > max 
        && ((i == end + 1 && idx > end + 1 + middle)
            || (i == pages - end - 1 && idx < pages - end + 1 - middle));
  }
  
  define pageIndex(index : Int, count : Int, perpage : Int, max: Int, end: Int) {
    var idx := max(1,index)
    var pages : Int := 1 + count/perpage
    var middle := (max - (2 * (end + 1)))/2
    container[class="pageIndex"] {
      if(pages > 1) { 
        if(idx > 1) { 
          container[class="indexEntryActive"]{ pageIndexLink(idx-1, "Previous") }
        } else { 
          container[class="indexEntryInactive"]{ "Previous" }
        }
        
        for(i : Int from 1 to pages+1) { 
          if(showIndex(i, idx, pages, max, middle, end)) {
            if(i == idx) {
              container[class="indexEntryCurrent"]{ output(i) }
            } else { 
              container[class="indexEntryActive"]{ pageIndexLink(i, i + "") }
            }
          } else { if(showGap(i, idx, pages, max, middle, end)) { 
              container[class="indexEntryGap"]{ "..." }
          } }
        }
        
        if(idx < pages) { 
          container[class="indexEntryActive"]{ pageIndexLink(idx+1,"Next") }
        } else { 
          container[class="indexEntryInactive"]{ "Next" }
        }
      }
    }
  }

  define span pageIndexUpto(index : Int, more : Bool) {
    var pages : Int := index
    if(index > 1) { 
      pageIndexLink(index-1, "Previous") 
    } else { 
      container[class="indexprevious"]{ "Previous" }
    }
    for(i : Int from 1 to pages+1) {  
      if(i == index) {
        container[class="current"]{ output(i) }
      } else { 
        container[class="indexpage"]{ pageIndexLink(i, i + "") }
      }
    }
    if(more) {
      pageIndexLink(index+1,"Next")
    } else {
      container[class="indexnext"]{ "Next" }
    }
  }
