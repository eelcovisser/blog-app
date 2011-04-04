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
  
  define rssWrapper(title: String, url: String) {
    var now := now()
    mimetype("application/rss+xml")
    <rss version="2.0">
      <channel> 
        <title>output(title)</title>
        <link>output(url)</link>
        <description>output(title)</description>
        <pubDate>output(now)</pubDate> 
        elements()
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
