document.write('<P>'+navigator.appName+'</P>');
document.write('<P>'+navigator.appVersion+'</P>');
document.write('<P>'+navigator.platform+'</P>');
document.write('<P>'+navigator.userAgent+'</P>');
	   
var plugins = navigator.plugins;
var mimeTypes = navigator.mimeTypes
	   
document.write('<P>');
for (i=0;i<plugins.length;i++) {
   var plugin = plugins[i];
   document.write('<B>'+plugin.name+'</B><BR>');
   document.write(plugin.filename+' - '+plugin.description+'<BR>');
   for(j=0;j<plugin.length;j++) {
      var mimetype = plugin[j];
      document.write(mimetype.type);
      if(mimetype.description) {
         document.write(' : '+mimetype.description);
      }
      if(mimetype.suffixes) {
         document.write(' - extentions: '+mimetype.suffixes);
      }
      document.write('<BR>');
   }
			
}
document.write('</P>');
