function request(url, type, callback, send){
    var oReq = new XMLHttpRequest();
    oReq.open(type, url, true);
    oReq.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    oReq.onload = callback;
    oReq.send(send);
};

function getListener () {
    var el = document.createElement('div');
    el.innerHTML = this.responseText;
    request('csrf.php', 'POST', postListener, 'csrf_token=' + el.querySelector('input[name="csrf_token"]').value + '&update_profile=value');
};

function postListener(){
    console.log(this.responseText)
};

request('csrf.php', 'GET', getListener);
