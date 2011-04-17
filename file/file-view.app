module file/file-view

imports file/file-model

access control rules

  rule template attachments(attachments: Ref<Attachments>) { attachments.mayView() }
  rule template attachmentsActions(attachments: Ref<Attachments>) { attachments.mayEdit() }
  
  rule template showAttachment(a: Attachment) { a.mayView() }
  rule template attachmentActions(a: Attachment) { a.mayEdit() }
  rule ajaxtemplate editAttachment(a: Attachment) { a.mayEdit() }
  rule page editAttachment(a: Attachment) { a.mayEdit() }

section attachments

  define attachments(attachments: Ref<Attachments>) {
    for(a: Attachment in attachments.attachments order by a.modified desc) { 
      showAttachment(a) 
    }
    attachmentsActions(attachments)
  }
  
  define attachmentsActions(attachments: Ref<Attachments>) {    
    action new() {
      var a := attachments.add();
      return editAttachment(a);
    }
    action publish() { attachments.publish(); }
    action hide() { attachments.hide(); }
    submitlink new() { "[Add Attachment]" } " "
    if(attachments.public()) {
      submitlink hide() { "[Hide Attachments]" }
    } else  {
      submitlink publish() { "[Publish Attachments]" }
    }
  }
  
section attachment
  
  define showAttachment(a: Attachment) {
    block[class="attachment"]{
      <h3>output(a.name)</h3>
      <div class="attachmentInfo">
	      <div class="attachmentActions">
	        downloadAttachment(a) " "
	        attachmentActions(a) 
	      </div>
	      <div class="attachmentModified">
	        "Last Modified: " output(a.modified) 
	      </div>
      </div>
      output(a.description)
    }
  }
  
  define attachmentActions(a: Attachment) {
    action edit() {
      //replace("editAttachment"+a.id, editAttachment(a));
      return editAttachment(a);
    }
    action delete() { a.attachments.remove(a); }
    action publish() { a.publish(); }
    action hide() { a.hide(); }
    submitlink edit() { "[Edit]" } " "
    if(a.public()) { 
       submitlink hide() { "[Hide]" }
     } else {
       submitlink publish() { "[Publish]" }
     } " " 
     submitlink delete() { "[Delete]" } 
     //placeholder "editAttachment"+a.id { }
  }
  
  define downloadAttachment(a: Attachment) {
    action download() { a.file.download(); }
    if(a.file != null) { downloadlink download() { "[Download]" } }
  }
  
  define ajax editAttachmentInline(a: Attachment) {
    action save() { a.modified(); }
    modalDialogPopup("editAttachment") {
      form{
        formEntry("Name") { input(a.name) }
        formEntry("File") { input(a.file) }
        submit save() { "Save" }
      }
    }
  }
  
  define page editAttachment(a : Attachment) {
    action save() { a.modified(); }
    main{
      <h1>"Attachment: " output(a.name)</h1>
      form{
        formEntry("Name") { input(a.name) }
        if(a.file != null) { 
          formEntry("Current File") { downloadAttachment(a) }
          formEntry("Replace File") { input(a.file) }
        } else {
          formEntry("File") { input(a.file) }
        }
        formEntry("Description") { input(a. description) }
        submit save() { "Save" }
      }
    }
  }
  
  