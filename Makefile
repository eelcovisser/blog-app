all : rebuild deploy

build : 
	webdsl build

rebuild: 
	webdsl rebuild

clean: 
	webdsl clean

deploy:
	webdsl deploy

css:
	cp stylesheets/common_.css stylesheets/eelcovisser.css /opt/tomcat/webapps/blog/stylesheets

