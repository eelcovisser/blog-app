module file/pdf-view

imports file/pdf-model

// upload PDF file
// show list of PDF files
// delete file
// show PDF file with thumbnail image
// download PDF file
// embed PDF file in page

  define page documents() { 
  	main{
  		header{"Documents"}
  		list{
  			for(pdf : PDF order by pdf.created desc) {
  				listitem{
  					
  				}
  			}
  		}
  	}
  }