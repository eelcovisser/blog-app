module lib/lib

imports lib/math
imports lib/pageindex
imports lib/string
imports lib/accesscontrol
imports lib/datetime
imports lib/markup 
imports lib/editable
imports lib/coordinates
imports lib/modal-dialog
imports lib/rss

section ajax lib

  define ajax empty() { }
  
access control rules

  rule ajaxtemplate empty() { true }
   
