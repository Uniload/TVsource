//=============================================================================
// LocalMessage
//
// LocalMessages are abstract classes which contain an array of localized text.  
// The PlayerController function ReceiveLocalizedMessage() is used to send messages 
// to a specific player by specifying the LocalMessage class and index.  This allows 
// the message to be localized on the client side, and saves network bandwidth since 
// the text is not sent.  Actors (such as the GameInfo) use one or more LocalMessage 
// classes to send messages.  The BroadcastHandler function BroadcastLocalizedMessage() 
// is used to broadcast localized messages to all the players.
//
//=============================================================================
class LocalMessage extends Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsSpecial;										// If true, don't add to normal queue.
var bool	bIsUnique;										// If true and special, only one can be in the HUD queue at a time.
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bFadeMessage;									// If true, use fade out effect on message.
var bool	bBeep;											// If true, beep!
var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var bool	bCenter;										// Whether or not to center the message.
var bool	bFromBottom;									// Subtract YPos.
var int		Lifetime;										// # of seconds to stay in HUD message queue.

var(Message) class<LocalMessage> ChildMessage;                      // In some cases, we need to refer to a child message.

var Color  DrawColor;
var float XPos, YPos;
var int FontSize;                                          // 0: Huge, 1: Big, 2: Small ...

#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	);

static function string GetRelatedString(
    optional int Switch,
    optional Core.Object Related1, 
    optional Core.Object Related2,
    optional Core.Object OptionalObject,
	optional String OptionalString
    )
{
    return static.GetString(Switch,Related1,Related2,OptionalObject,OptionalString);
}

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	)
{
	if ( class<Actor>(OptionalObject) != None )
		return class<Actor>(OptionalObject).static.GetLocalString(Switch, Related1, Related2);
	return "";
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional Core.Object Related1, 
	optional String MessageString
	)
{
	return "";
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	)
{
	if ( P.myHUD != None )
	P.myHUD.LocalizedMessage( Default.Class, Switch, Related1, Related2, OptionalObject,,OptionalString );

    if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
		P.Player.InteractionMaster.Process_Message( Static.GetString( Switch, Related1, Related2, OptionalObject, OptionalString ), 6.0, P.Player.LocalInteractions);
}

static function color GetConsoleColor( Core.Object Related1 )
{
    return Default.DrawColor;
}

static function color GetColor(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2
	)
{
	return Default.DrawColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos;
}

static function int GetFontSize( int Switch, Core.Object RelatedPRI1, Core.Object RelatedPRI2, Core.Object LocalPlayer )
{
    return default.FontSize;
}

static function float GetLifeTime(int Switch)
{
    return default.Lifetime;
}

#else
static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject
	);

static function string GetRelatedString(
    optional int Switch,
    optional Core.Object Related1, 
    optional Core.Object Related2,
    optional Core.Object OptionalObject
    )
{
    return static.GetString(Switch,Related1,Related2,OptionalObject);
}

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject
	)
{
	if ( class<Actor>(OptionalObject) != None )
		return class<Actor>(OptionalObject).static.GetLocalString(Switch, Related1, Related2);
	return "";
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional Core.Object Related1, 
	optional String MessageString
	)
{
	return "";
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject
	)
{
	if ( P.myHUD != None )
	P.myHUD.LocalizedMessage( Default.Class, Switch, Related1, Related2, OptionalObject );

    if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
		P.Player.InteractionMaster.Process_Message( Static.GetString( Switch, Related1, Related2, OptionalObject ), 6.0, P.Player.LocalInteractions);
}

static function color GetConsoleColor( Core.Object Related1 )
{
    return Default.DrawColor;
}

static function color GetColor(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2
	)
{
	return Default.DrawColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos;
}

static function int GetFontSize( int Switch, Core.Object RelatedPRI1, Core.Object RelatedPRI2, Core.Object LocalPlayer )
{
    return default.FontSize;
}

static function float GetLifeTime(int Switch)
{
    return default.Lifetime;
}
#endif

defaultproperties
{
     bIsSpecial=True
     bIsConsoleMessage=True
     lifetime=5
     DrawColor=(B=255,G=255,R=255,A=255)
     XPos=0.500000
     YPos=0.700000
}
