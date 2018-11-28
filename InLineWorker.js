var targetURL = window.location;

window.URL = window.URL || window.webkitURL;

var code = "/* JS code to be executed in the worker */";

var blob;
try {
    blob = new Blob([code], {type: 'application/javascript'});
} catch (e) { 
    window.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder;
    blob = new BlobBuilder();
    blob.append(code);
    blob = blob.getBlob();
}
var worker = new Worker(URL.createObjectURL(blob));
