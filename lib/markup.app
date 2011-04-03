module lib/markup 
  
section markup

  define span header1(){ <h1> elements </h1> }
  define span header2(){ <h2> elements </h2> }
  define span header3(){ <h3> elements </h3> }
  define span header4(){ <h4> elements </h4> }

section forms

  define formEntry(l: String){ 
    <div class="formentry">
      <span class="formentrylabel">output(l)</span>
      elements
    </div>
  }
  