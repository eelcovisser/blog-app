module lib/rss

section RSS
  
  define span rssWrapper() {
    //mimetype("text/xml")
    mimetype("application/rss+xml")
    //<?xml version="1.0" encoding="utf-8" ?>
    <rss version="2.0">
       elements()
    </rss>
  }
  
  define rssDateTime(d: DateTime) {
    output(d.format("EEE, dd MMM yyyy hh:mm:ss zzz"))
  }
  
  // see http://www.rssboard.org/rss-specification for documentation
  
  define rssWrapper(title: String, url: String, desc: Text, pubDate: DateTime) {
    var now := now()
    mimetype("application/rss+xml")
    <rss version="2.0">
      <channel> 
        <title>output(title)</title>
        <link>output(url)</link>
        if(!isEmptyString(desc)){ <description>output(desc)</description> }
        if(pubDate != null) { <pubDate>rssDateTime(pubDate)</pubDate> }
        <docs>"http://www.rssboard.org/rss-specification"</docs>
        //<language></language>
        //<copyright></copyright>
        elements
      </channel>
    </rss>
  }
  
      //   <item> 
      //   <title>output(pub.title)</title>
      //   <link>output(navigate(publication(pub,"","")))</link>
      //   <description>citation(pub)</description>
      //   <guid>output(navigate(publication(pub,"","")))</guid>
      //   <pubDate>output(pub.created)</pubDate>
      // </item>
