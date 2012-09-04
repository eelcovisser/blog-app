module file/pdf-model

  entity PDF {
    file        :: File // todo: validate: check that this is a PDF file
    filename    :: String (name)
    created     :: DateTime (default=now())
    modified    :: DateTime (default=now())
  }
    
  // compute thumbnail for PDF file (image)
  // compute hash of contents of PDF file
  // use hash as index; when adding new PDF file return existing object if hash is same
  // change file name of File object
  // validate that file is indeed a PDF file