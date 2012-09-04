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
    attachmentsActions(attachments)
    if(attachments.attachments.length > 0) {
      div[class="attachments"]{
        tableBordered{
          for(a: Attachment in attachments.attachments order by a.modified desc) { 
            showAttachment(a) 
          }
        }
      }
    }
  }
  
  define attachmentsActions(attachments: Ref<Attachments>) {    
    action new() {
      var a := attachments.add();
      return editAttachment(a);
    }
    action publish() { attachments.publish(); }
    action hide() { attachments.hide(); }
    submitlink new() [class="btn"] { "Add Attachment" } " "
    if(attachments.public()) {
      submitlink hide() [class="btn"] { "Hide Attachments" }
    } else  {
      submitlink publish() [class="btn"] { "Publish Attachments" }
    }
  }
  
section attachment
  
  define showAttachment(a: Attachment) {
    row{
      column{ output(a.name) }
      column{ output(a.modified) }
      column{ output(a.description) }
      column{ downloadAttachment(a) " " attachmentActions(a) }
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
    submitlink edit() [class="btn"] { "Edit" } " "
    if(a.public()) { 
       submitlink hide() [class="btn"] { "Hide" }
     } else {
       submitlink publish() [class="btn"] { "Publish" }
     } " " 
     submitlink delete() [class="btn"] { "Delete" } 
     //placeholder "editAttachment"+a.id { }
  }
  
  define downloadAttachment(a: Attachment) {
    action download() { a.file.download(); }
    if(a.file != null) { downloadlink download() [class="btn"] { "Download" } }
  }
  
  define ajax editAttachmentInline(a: Attachment) {
    action save() { a.modified(); }
    modalDialogPopup("editAttachment") {
      horizontalForm{
        controlGroup("Name") { input(a.name) }
        controlGroup("File") { input(a.file) }
        formActions{ submit save() [class="btn"] { "Save" } }
      }
    }
  }
  
  define page editAttachment(a : Attachment) {
    action save() { a.modified(); }
    wikilayout{
      pageHeader2{ "Attachment: " output(a.name) }
      horizontalForm{
        controlGroup("Name") { input(a.name) }
        if(a.file != null) { 
          controlGroup("Current File") { downloadAttachment(a) }
          controlGroup("Replace File") { input(a.file) }
        } else {
          controlGroup("File") { input(a.file) }
        }
        controlGroup("Description") { input(a. description) }
        formActions{ 
          submit save() [class="btn"] { "Save" }
        }
      }
    }
  }
  
  