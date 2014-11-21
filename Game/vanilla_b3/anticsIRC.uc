class anticsIRC extends IpDrv.TcpLink config(antics);

var string CRLF; // Carriage return line feed.
var config string DefaultChannel; // Default IRC channel.
var config string DefaultChannelPassword; // Default IRC channel password.
var config int DefaultPort; // Default IRC port.
var config string DefaultServer; // Default IRC server.
var config string Email; // IRC e-mail address.
var config array<string> LogRecipient; // Nicks/Channels to receive logs.
var config string Nick; // IRC nickname.
var config string NickPassword; // IRC nickname password.

function Connect(optional string ServerAddress)
{
	local int i;
	CRLF = Chr(10) $ Chr(13);
	
	if(ServerAddress != "")
	{
		i = InStr(ServerAddress, ":");
	
		if(i == -1)
			DefaultServer = ServerAddress;
		else
		{
			DefaultServer = Left(ServerAddress, i);
			DefaultPort = Int(Mid(ServerAddress, i + 1));
		}
	}

	log("Attempting to resolve" @ DefaultServer $ "...", 'antics');
	Resolve(DefaultServer);
}

event Resolved(IpAddr Addr)
{
	log("Resolved" @ DefaultServer $ "! Binding to port" @ DefaultPort $ "...", 'antics');
	Addr.Port = DefaultPort;
	BindPort();
	
	log("Bound to port" @ DefaultPort $ "! Setting receive and link modes...", 'antics');
	ReceiveMode = RMODE_Event;
	LinkMode = MODE_Text;
	
	log("Receive and link modes set! Opening connection...", 'antics');
	Open(Addr);
}

event ResolveFailed()
{
	log("Could not resolve" @ DefaultServer $ "!", 'antics');
}

event Opened()
{
	log("Connection  to" @ DefaultServer @ "established!", 'antics');
	
	SaveConfig();
	
	Login();
}

function Login()
{
	IdentifyUser(Nick, Email);
	SetNick(Nick);
	IdentifyNick(NickPassword);
	JoinChannel(DefaultChannel, DefaultChannelPassword);
}

function IdentifyUser(string nickname, string email)
{
	SendText("USER" @ nickname @ email @ DefaultServer @ ":" $ nickname);
}

function SetNick(string nickname)
{
	SendText("NICK" @ nickname);
}

function IdentifyNick(string password)
{
	SendMessage("IDENTIFY" @ password, "NickServ");
}

function JoinChannel(string channel, string password)
{
	SendText("JOIN" @ channel @ password);
}

function SendMessage(string message, optional string channel)
{
	local int i;
	
	if(channel != "")
	{
		SendText("PRIVMSG" @ channel @ ":" $ message);
		return;
	}
	
	SendText("PRIVMSG" @ DefaultChannel @ ":" $ message);
	
	for(i = 0; i < LogRecipient.Length; i++)
	{
		SendText("PRIVMSG" @ LogRecipient[i] @ ":" $ message);
	}
}

function int SendText(coerce string Str)
{
	return Super.SendText(Str $ CRLF);
}

event ReceivedText(string Text)
{
	if(Left(Text, 5) == "PING ")
		SendText("PONG " $ Mid(Text, 5));
}

event Closed()
{
	log("Connection  to" @ DefaultServer @ "closed!", 'antics');
}

defaultproperties
{
     DefaultChannel="#antics"
     DefaultPort=6667
     DefaultServer="irc.tribalwar.com"
}
