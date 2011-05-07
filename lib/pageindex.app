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
  
  function pageIndexIntervals(idx : Int, count : Int, perpage : Int, max: Int, end: Int): List<List<Int>> {
    var pages : Int := 1 + (count - 1)/perpage;
    var middle := (max - (2 * (end + 1)))/2;  
    var intervals : List<List<Int>>;
    if(pages <= max) {
      intervals := [[1,pages]];
    } else { if(idx <= end + 2 + middle) {
      intervals := [[1, end + 1 + 2 * middle], [pages - end + 1, pages]];
    } else { if(idx >= pages - end - middle) {
      intervals := [[1,end], [pages - end - 2 * middle, pages]];
    } else {
      intervals := [[1, end], [idx - middle, idx + middle - 1], [pages - end + 1, pages]];
    }}}
    return intervals;
  }
  
  define pageIndex(index : Int, count : Int, perpage : Int, max: Int, end: Int) {
    var idx := max(1,index)
    var pages : Int := 1 + (count - 1)/perpage
    var intervals : List<List<Int>> := pageIndexIntervals(idx, count, perpage, max, end)
    if(pages > 1) { 
      container[class="pageIndex"] {
        if(idx > 1) { 
          container[class="indexEntryActive"]{ pageIndexLink(idx-1, "Previous") }
        } else { 
          container[class="indexEntryInactive"]{ "Previous" }
        }
        for(iv : List<Int> in intervals) {
	        for(i : Int from iv.get(0) to iv.get(1) + 1) { 
	          if(i == idx) {
	            container[class="indexEntryCurrent"]{ output(i) }
	          } else { 
	            container[class="indexEntryActive"]{ pageIndexLink(i, i + "") }
	          }
	        }
        } separated-by {
          container[class="indexEntryGap"]{ "..." }
        }
        if(idx < pages) { 
          container[class="indexEntryActive"]{ pageIndexLink(idx+1,"Next") }
        } else { 
          container[class="indexEntryInactive"]{ "Next" }
        }
      }
    }
  }
    
  // function showIndex(i: Int, idx: Int, pages: Int, max: Int, middle: Int, end: Int): Bool {    
  //   if(pages <= max) {
  //     return true;
  //   } else { if(idx <= end + 1 + middle) {
  //     return i <= end + 1 + 2 * middle 
  //          || i > pages - end;
  //   } else { if(idx >= pages - end + 1 - middle) { 
  //     return i >= pages - end + 1 - 2 * middle
  //         || i <= end;
  //   } else { 
  //     return i <= end 
  //         || i > pages - end
  //         || (i > idx - middle && i <= idx + middle);
  //   } } }
  // }
  // 
  // function showGap(i: Int, idx: Int, pages: Int, max: Int, middle: Int, end: Int): Bool {
  //   return pages > max 
  //       && ((i == end + 1 && idx > end + 1 + middle)
  //           || (i == pages - end - 1 && idx < pages - end + 1 - middle));
  // }
  // 
  // define pageIndexOld(index : Int, count : Int, perpage : Int, max: Int, end: Int) {
  //   var idx := max(1,index)
  //   var pages : Int := 1 + count/perpage
  //   var middle := (max - (2 * (end + 1)))/2
  //   container[class="pageIndex"] {
  //     if(pages > 1) { 
  //       if(idx > 1) { 
  //         container[class="indexEntryActive"]{ pageIndexLink(idx-1, "Previous") }
  //       } else { 
  //         container[class="indexEntryInactive"]{ "Previous" }
  //       }
  //       
  //       for(i : Int from 1 to pages+1) { 
  //         if(showIndex(i, idx, pages, max, middle, end)) {
  //           if(i == idx) {
  //             container[class="indexEntryCurrent"]{ output(i) }
  //           } else { 
  //             container[class="indexEntryActive"]{ pageIndexLink(i, i + "") }
  //           }
  //         } else { if(showGap(i, idx, pages, max, middle, end)) { 
  //             container[class="indexEntryGap"]{ "..." }
  //         } }
  //       }
  //       
  //       if(idx < pages) { 
  //         container[class="indexEntryActive"]{ pageIndexLink(idx+1,"Next") }
  //       } else { 
  //         container[class="indexEntryInactive"]{ "Next" }
  //       }
  //     }
  //   }
  // }

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
