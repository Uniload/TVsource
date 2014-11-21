// ====================================================================
//  Class:  TribesGui.TribesMPCommunityPanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesIRCPage extends TribesGUIPanel
     ;

var(TribesGui) EditInline Config GUIEditBox         ed_TextEntry;
var automated GUISplitter       sp_Main;
var() config float              MainSplitterPosition;

var(TribesGui) EditInline Config GUIScrollTextBox            lb_TextDisplay;

var localized string HasLeftText;
var localized string HasJoinedText;
var localized string WasKickedByText;
var localized string NowKnownAsText;
var localized string QuitText;
var localized string SetsModeText;
var localized string NewTopicText;

var config int MaxChatScrollback;
var config int InputHistorySize;
var globalconfig bool bIRCTextToSpeechEnabled;

var transient array<string> InputHistory;
var transient int           InputHistoryPos;
var transient bool          bDoneInputScroll;

var config color IRCTextColor;
var config color IRCNickColor;
var config color IRCActionColor;
var config color IRCInfoColor;
var config color IRCLinkColor;

var GUIButton MyButton;

// Pure Virtual
function ProcessInput(string Text)
{

}

// This disconnects the IRC client at map change!!
function Free( optional bool bForce )
{
}

// When you hit enter in the input box, call the class
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local string Input;
    local int Index;

	//log("key press "$Key$" state "$state);
    if ( (key==0xEC) && (State==3) )
    {

        lb_TextDisplay.MyScrollText.WheelUp();
        return true;
    }

    if ( (key==0xED) && (State==3) )
    {

        lb_TextDisplay.MyScrollText.WheelDown();
        return true;
    }

    // Only care about key-press events
    if(State != 1)
	    return ed_TextEntry.InternalOnKeyEvent(Key, State, delta);

    if( Key == 0x0D ) // ENTER
    {
        Input = ed_TextEntry.GetText();

        if(Input != "")
        {
            // Add string to end of history
            Index = InputHistory.Length;
            InputHistory.Insert(Index, 1);
            InputHistory[Index] = Input;

            // If history is too long, remove chat from start of history
            if(InputHistory.Length > InputHistorySize)
                InputHistory.Remove(0, InputHistory.Length - InputHistorySize);

            // Once you enter something - reset history position to most recent entry
            InputHistoryPos = InputHistory.Length - 1;
            bDoneInputScroll = false;

            ProcessInput(Input); // Handle whatever you typed
            ed_TextEntry.SetText(""); // And empty box again.
        }

        return true;
    }
    else if( Key == 0x26 ) // UP
    {
        if( InputHistory.Length > 0 ) // do nothing if no history
        {
            ed_TextEntry.SetText( InputHistory[ InputHistoryPos ] );

            InputHistoryPos--;
            if(InputHistoryPos < 0)
                InputHistoryPos = InputHistory.Length - 1;

            bDoneInputScroll = true;
        }

        return true;
    }
    else if( Key == 0x28 ) // DOWN
    {
        if( InputHistory.Length > 0 )
        {
            if(!bDoneInputScroll)
                InputHistoryPos = 0; // Hack so pressing 'down' gives you the oldest input

            ed_TextEntry.SetText( InputHistory[ InputHistoryPos ] );

            InputHistoryPos++;
            if(InputHistoryPos > InputHistory.Length - 1)
                InputHistoryPos = 0;

            bDoneInputScroll = true;
        }

        return true;
    }

    return ed_TextEntry.InternalOnKeyEvent(Key, State, delta);
}


function string ColorizeLinks(string InString)
{
    local int i;
    local string OutString, Character, Word, ColourlessWord;
    local bool InWord, HaveWord;

    i=0;
    while(true)
    {
        // Get the next word in the string
        while( i<Len(InString) && !HaveWord )
        {
            Character = Mid(InString, i, 1);

            if(InWord) // We are in the middle of a word.
            {
                if( Character == " " ) // We hit a terminating space - word complete
                {
                    HaveWord = true;
                }
                else // We are just working through the word
                {
                    Word = Word $ Character;
                    i++;
                }
            }
            else
            {
                if( Character == " " ) // Pass over spaces (add straight to output)
                {
                    OutString = OutString $ Character;
                    i++;
                }
                else // Hit the first character of a word.
                {
                    InWord = true;
                    Word = Word $ Character;
                    i++;
                }
            }
        }

        if(Word == "")
            return OutString;

        // Deal with that word
        ColourlessWord = StripColorCodes(Word);
        if( Left(ColourlessWord, 7) == "http://" || Left(ColourlessWord, 9) == "tribes://" || Left(ColourlessWord, Len(PlayerOwner().GetURLProtocol())+3)==(PlayerOwner().GetURLProtocol()$"://") )
            OutString = OutString$MakeColorCode(IRCLinkColor)$ColourlessWord$MakeColorCode(IRCTextColor);
        else
            OutString = OutString$Word;

        // Reset for next word;
        Word = "";
        HaveWord = false;
        InWord = false;
    }

    return OutString;
}

function IRCTextDblClick(GUIComponent Sender)
{
    local string ClickString;

    ClickString = StripColorCodes(lb_TextDisplay.MyScrollText.ClickedString);
   //	Controller.LaunchURL(ClickString);
}

function InitComponent(GUIComponent MyOwner)
{
    Super.Initcomponent(MyOwner);

	lb_TextDisplay = GUIScrollTextBox(AddComponent("GUI.GUIScrollTextBox", self.Name$"_GUIScrollTextBox", false ));

    lb_TextDisplay.MyScrollText.MaxHistory = MaxChatScrollback;
    lb_TextDisplay.MyScrollText.bClickText = true;
    lb_TextDisplay.MyScrollText.OnDblClick = IRCTextDblClick;

    lb_TextDisplay.MyScrollText.SetFocusInstead(ed_TextEntry);
    lb_TextDisplay.MyScrollText.bNeverFocus = True;
	lb_TextDisplay.MyScrollText.bAllowHTMLTextFormatting = True;

		// MJ:  Moved textdisplay init from below to here
    lb_TextDisplay.bVisibleWhenEmpty = True;
    lb_TextDisplay.CharDelay = 0.0015;
    lb_TextDisplay.EOLDelay = 0.25;
    //lb_TextDisplay.Separator = Chr(13);
    lb_TextDisplay.bVisibleWhenEmpty = True;
    lb_TextDisplay.bNoTeletype = True;
	lb_TextDisplay.bStripColors = True;
	lb_TextDisplay.SetFocusInstead(ed_TextEntry);

	// MJ:  Hard-code size for now
	lb_TextDisplay.bAllowHTMLTextFormatting = True;
	lb_TextDisplay.WinTop=0.00000;
	lb_TextDisplay.WinLeft=0.00000;
	lb_TextDisplay.WinWidth=0.78500;
	lb_TextDisplay.WinHeight=0.846000;
    //lb_TextDisplay.StyleName = "IRCText";
	lb_TextDisplay.InitComponent(self);

	ed_TextEntry = GUIEditBox(AddComponent("GUI.GUIEditBox", self.Name$"_GUIEditBox", false ));
	ed_TextEntry.WinTop=0.866000;
	ed_TextEntry.WinLeft=0.00000;
	ed_TextEntry.WinWidth=0.785000;
	ed_TextEntry.WinHeight=0.06;
    ed_TextEntry.SetText("");
	ed_TextEntry.StyleName = "STY_StretchedButton";
	ed_TextEntry.InitComponent(self);
	ed_TextEntry.OnKeyEvent = InternalOnKeyEvent;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	// MJ:  This never gets called because it doesn't exist in our system
	Log("IRC: "$self$" called IntOnCC()");
    if (GUIScrollTextBox(NewComp) != None)
    {
        lb_TextDisplay = GUIScrollTextBox(NewComp);
        lb_TextDisplay.bVisibleWhenEmpty = True;
        lb_TextDisplay.WinWidth = 1.0;
        lb_TextDisplay.WinHeight = 1.0;

        lb_TextDisplay.CharDelay = 0.0015;
        lb_TextDisplay.EOLDelay = 0.25;
        //lb_TextDisplay.Separator = Chr(13);
        lb_TextDisplay.bVisibleWhenEmpty = True;
        lb_TextDisplay.bNoTeletype = True;

        lb_TextDisplay.StyleName = "IRCText";
    }
}

function InterpretColorCodes( out string Text )
{
	local int Pos;
	local string Code;

	Pos = InStr(Text, Chr(3));

	while ( Pos != -1 )
	{
		Pos++;
		Code = "";

		while ( IsDigit(Mid(Text,Pos,1)) )
		{
			Code = Code $ Mid(Text,Pos,1);
			Pos++;
		}

		if ( Code != "" && Mid(Text,Pos,1) == "," )
		{
			Text = Left(Text,Pos) $ Mid(Text,Pos+1);
			while ( IsDigit(Mid(Text,Pos,1)) )
				Text = Left(Text,Pos) $ Mid(Text,Pos+1);
		}

		Text = Repl( Text, Chr(3) $ Code, MakeColorCode(DecodeColor(int(Code))) );
		Pos = InStr(Text,Chr(3));
	}
}

function color DecodeColor( int ColorCode )
{
	local color C;

	switch ( ColorCode )
	{
		case 2:
			C = class'Canvas'.static.MakeColor(0,0,127);
			break;

		case 3:
			C = class'Canvas'.static.MakeColor(0,147,0);
			break;

		case 4:
			C = class'Canvas'.static.MakeColor(255,0,0);
			break;

		case 5:
			C = class'Canvas'.static.MakeColor(127,0,0);
			break;

		case 6:
			C = class'Canvas'.static.MakeColor(156,0,156);
			break;

		case 7:
			C = class'Canvas'.static.MakeColor(252,127,0);
			break;

		case 8:
			C = class'Canvas'.static.MakeColor(255,255,0);
			break;

		case 9:
			C = class'Canvas'.static.MakeColor(0,255,0);
			break;

		case 10:
			C = class'Canvas'.static.MakeColor(0,147,147);
			break;

		case 11:
			C = class'Canvas'.static.MakeColor(0,255,255);
			break;

		case 12:
			C = class'Canvas'.static.MakeColor(0,0,252);
			break;

		case 13:
			C = class'Canvas'.static.MakeColor(255,0,255);
			break;

		case 14:
			C = class'Canvas'.static.MakeColor(127,127,127);
			break;

		case 15:
			C = class'Canvas'.static.MakeColor(210,210,210);
			break;

		default:
			C = class'Canvas'.static.MakeColor(255,255,255);

	}

	return C;
}

defaultproperties
{
    //Begin Object class=moEditBox Name=EntryBox
    //    WinWidth=1.0
    //    WinHeight=0.05
    //    WinLeft=0
    //    WinTop=0.95
    //    CaptionWidth=0
    //    StyleName="IRCEntry"
    //    bBoundToParent=True
    //    bScaleToParent=True
    //    OnKeyEvent=InternalOnKeyEvent
    //    TabOrder=0
    //End Object
    //ed_TextEntry=EntryBox

    //WinTop=0.0
    //WinLeft=0
    //WinWidth=1
    //WinHeight=1
    bAcceptsInput=false

    MaxChatScrollback=250
    InputHistorySize=16

    HasLeftText="%Name% has left %Chan%."
    HasJoinedText="%Name% has joined %Chan%."
    WasKickedByText="%Kicked% was kicked by %Kicker% ( %Reason% )."
    NowKnownAsText="%OldName% is now known as %NewName%."
    QuitText="*** %Name% Quit ( %Reason% )"
    SetsModeText="*** %Name% sets mode: %mode%."
    NewTopicText="Topic"

    IRCTextColor=(R=160,G=160,B=160,A=0)
    IRCNickColor=(R=150,G=150,B=255,A=0)
    IRCActionColor=(R=230,G=200,B=0,A=0)
    IRCInfoColor=(R=130,G=130,B=160,A=0)
    IRCLinkColor=(R=255,G=150,B=150,A=0)
	bIRCTextToSpeechEnabled=True
}
