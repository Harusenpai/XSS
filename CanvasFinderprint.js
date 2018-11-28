/* @CC_SKIP< */
if (typeof window.atob == 'undefined') {
    function atob(a){
        var b="",e,c,h="",f,g="",d=0;
        k="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        do e=k.indexOf(a.charAt(d++)),c=k.indexOf(a.charAt(d++)),f=k.indexOf(a.charAt(d++)),g=k.indexOf(a.charAt(d++)),e=e<<2|c>>4,c=(c&15)<<4|f>>2,h=(f&3)<<6|g,b+=String.fromCharCode(e),64!=f&&(b+=String.fromCharCode(c)),64!=g&&(b+=String.fromCharCode(h));
        while(d<a.length);
        return unescape(b)
    };
}/* @CC_SKIP> */

function bin2hex(a){
    var b,c,d="",e;
    a+="";
    b=0;
    for(c=a.length;b<c;b++)e=a.charCodeAt(b).toString(16),d+=2>e.length?"0"+e:e;
    return d
}

function draw_canvas(){
    var a=document.createElement("canvas");
    a.setAttribute("width",220);
    a.setAttribute("height",30);
    var b=a.getContext("2d");
    b.textBaseline="top";
    b.font="14px 'Arial'";
    b.textBaseline="alphabetic";
    b.fillStyle="#f60";
    b.fillRect(125,1,62,20);
    b.fillStyle="#069";
    b.fillText("BrowserLeaks,com <canvas> 1.0",2,15);
    b.fillStyle="rgba(102, 204, 0, 0.7)";
    b.fillText("BrowserLeaks,com <canvas> 1.0",4,17);
    a=a.toDataURL("image/png");
    b=atob(a.replace("data:image/png;base64,",""));    
    return bin2hex(b.slice(-16,-12))
}

var fingerprint = draw_canvas();
new Image().src = "http://wherever/fingerpint.php?fp="+fingerprint;