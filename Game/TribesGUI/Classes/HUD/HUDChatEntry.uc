//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class HUDChatEntry extends LabelElement;

// Constants.
const MaxHistory=20;		// # of command histroy to remember.

// Variables

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[MaxHistory]; 	// Holds the current command, and the history
var bool bTyping;							// Turn when someone is typing on the console
var bool bIgnoreKeys;						// Ignore Key presses until a new KeyDown is received
var bool bTeamText;

var int MaxMessageTextLength;

var localized string allText;
var localized string teamText;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	if(c.bTalk || c.bTeamTalk)
	{
		bTeamText = c.bTeamTalk;
		if(! bTyping)
		{
			bTyping = true;
			bVisible= true;
			bIgnoreKeys = true;
			HistoryCur = HistoryTop;
			SetText(TypedStr);
		}
	}
	else
	{
		bTyping = false;
		bVisible = false;
	}
}

function SetText(String str)
{
	if (bTeamText)
		super.SetText(teamText$str$"_");
	else
		super.SetText(allText$str$"_");
}

function bool KeyType( EInputKey Key, string Unicode, HUDAction Response )
{
	if(! bTyping)
		return false;

	if (bIgnoreKeys)
		return true;

	if(Len(TypedStr) > MaxMessageTextLength)
		return false;

	if( Key>=0x20 && Key<0x100 && Key!=Asc("~") && Key!=Asc("`") )
	{
		if( Unicode != "" )
			TypedStr = TypedStr $ Unicode;
		else
			TypedStr = TypedStr $ Chr(Key);

		SetText(TypedStr);
		return true;
	}
}
function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response )
{
	local string Temp;

	if(! bTyping)
		return false;

	if (Action== IST_Press)
	{
		bIgnoreKeys=false;
	}

	if( Key==IK_Escape )
	{
		if( TypedStr!="" )
		{
			TypedStr="";
			HistoryCur = HistoryTop;
			return true;
		}
		else
		{
			Response.CancelChat();
		}
	}
	else if( Action != IST_Press )
	{
		return false;
	}
	else if( Key==IK_Enter )
	{
		if( TypedStr!="" )
		{
			// Print to console.
//			Message( TypedStr, 6.0 );

			History[HistoryTop] = TypedStr;
			HistoryTop = (HistoryTop+1) % MaxHistory;

			if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
				HistoryBot = (HistoryBot+1) % MaxHistory;

			HistoryCur = HistoryTop;

			// Make a local copy of the string.
			Temp=TypedStr;
			TypedStr="";
/*
			if( !ConsoleCommand( Temp ) )
				Message( Localize("Errors","Exec","Core"), 6.0 );

			Message( "", 6.0 );
			
*/			Response.SendChatMessage(Temp);
			Response.CancelChat();
		}
		else
			Response.CancelChat();

		return true;
	}
	else if( Key==IK_Up )
	{
		if ( HistoryBot >= 0 )
		{
			if (HistoryCur == HistoryBot)
				HistoryCur = HistoryTop;
			else
			{
				HistoryCur--;
				if (HistoryCur<0)
					HistoryCur = MaxHistory-1;
			}

			TypedStr = History[HistoryCur];
			SetText(TypedStr);
		}
		return true;
	}
	else if( Key==IK_Down )
	{
		if ( HistoryBot >= 0 )
		{
			if (HistoryCur == HistoryTop)
				HistoryCur = HistoryBot;
			else
				HistoryCur = (HistoryCur+1) % MaxHistory;

			TypedStr = History[HistoryCur];
			SetText(TypedStr);
		}

	}
	else if( Key==IK_Backspace || Key==IK_Left )
	{
		if( Len(TypedStr)>0 )
		{
			TypedStr = Left(TypedStr,Len(TypedStr)-1);
			SetText(TypedStr);
		}
		return true;
	}
	return true;
}

defaultproperties
{
	bVisible		= false
	bAutoSize		= false

	bAutoWrapText	= false
	bAutoScrollText	= true
	bTyping		= false

	HistoryBot		= -1

	allText = "ALL: "
	teamText = "TEAM: "

	MaxMessageTextLength = 196
}