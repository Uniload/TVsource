class HUDMessagePane extends HUDList;

import enum EMessageType from ClientSideCharacter;

var() config String TemplateMessageLabelName	"Name of the template label properties";
var() config int	MaxMessages					"Max numer of messages to be displayed at once";
var() config int	MaxDisplayableLines			"Max number of actual text lines allowed in the display";

var() config bool	bAlwaysVisible				"Whether the message window is always visible";
var() config bool	bScrollable					"Whether the message window is scrollable";

var() config float	MessageFadeDuration			"How long irrelevant messages should take to fade away";
var() config float	MessageLifetime				"Fixed lifetime for messages";
var() config float	SecondsPerWord				"Number of seconds per word";
var() config float	MinimumLifetime				"Lower bound on message lifetime";

var() config String MessageStyles[EMessageType.MAX_MESSAGE_TYPES];

var HUDTextMessage PaddingMessage;
var int TotalLines;
var int FirstLineOffset;

var ObjectPool MessagePool;

function InitElement()
{
	super.InitElement();

	MessagePool = new class'Engine.ObjectPool';
}

// functions to be implemented in subclasses
function GetNewMessages(ClientSideCharacter c);

// will only be valid after the window HAS a message
function int GetLineHeight(Canvas canvas)
{
	if(children[0] != None)
		return HUDMessage(children[0]).GetLineHeight(canvas);

	// default value?
	return 8;
}

function UpdateData(ClientSideCharacter c)
{
	// get the messages from the clientsidecharacter
	GetNewMessages(c);

	// update the data after new messages have been added,
	// so that they get the current TimeSeconds
	super.UpdateData(c);

	// check all the messages for validity
	UpdateMessageVisibility();
}

function AddMessage(HUDMessage newMessage)
{
	local Array<String> messageWords;
	
	newMessage.AppearTime = TimeSeconds;
	newMessage.FadeOutDuration = MessageFadeDuration;
	if(MessageLifetime > 0)
		newMessage.Lifetime = MessageLifetime;
	else if(SecondsPerWord > 0)
		newMessage.Lifetime = Max(MinimumLifetime, SecondsPerWord * Split(newMessage.GetText(), " ", messageWords));
	else
		newMessage.Lifetime = -1;

	newMessage.Reset();

	AddExistingElement(newMessage);
}

function ScrollMessages(int ScrollDelta)
{
	FirstLineOffset += ScrollDelta;

	FirstLineOffset = Clamp(FirstLineOffset, maxDisplayableLines - TotalLines, 0);

	SetNeedsLayout();
}

function UpdateMessageVisibility()
{
	local int i;
	local HUDMessage nextMessage;

	if(bScrollable)
		return;

	for(i = children.Length - MaxMessages; i >= 0; --i)
	{
		MessagePool.FreeObject(Children[i]);
		RemoveElementAt(i);
	}

	// check all the messages to see if they should be
	// still hanging around
	for(i = 0; i < children.Length; ++i)
	{
		nextMessage = HUDMessage(children[i]);
		nextMessage.UpdateVisibility();

		if(nextMessage.bVisible == false)
		{
			RemoveElementAt(i--);
			MessagePool.FreeObject(nextMessage);
		}
	}
}

function DoLayout(Canvas c)
{
	local int i, numLines, LineOffset;
	local HUDMessage nextMessage;
	local String Padding;

	super.DoLayout(c);

	TotalLines = 0;
	LineOffset = FirstLineOffset;

	if(bScrollable)
	{
		if(PaddingMessage == None)
		{
			PaddingMessage = HUDTextMessage(CreateHUDElement(class'TribesGUI.HUDTextMessage', ""));
			PaddingMessage.ParentElement = self;
		}
	
		if(children.Length == 0 || children[0] != PaddingMessage)
		{
			children.Insert(0, 1);
			children[0] = PaddingMessage;
		}
		PaddingMessage.bVisible = false;

		// check messages to ensure the first message
		// is only rendering from the correct line
		for(i = children.Length - 1; i >= 0; --i)
		{
			if(children[i] != PaddingMessage)
			{
				nextMessage = HUDMessage(children[i]);

				// if we are already over the limit, mark the message as irrelevant
				if(numLines >= maxDisplayableLines)
					nextMessage.bVisible = false;

				TotalLines += nextMessage.GetNumLines();

				if(LineOffset >= 0)
				{
					nextMessage.bVisible = true;
					numLines += nextMessage.GetNumLines();

					// doing this means that messages will only display from the 
					// first line which fits onto the display, this could mean none 
					// of the message gets displayed.
					if(numLines > maxDisplayableLines)
						nextMessage.SetFirstVisibleLine(numLines - maxDisplayableLines);
					else
						nextMessage.SetFirstVisibleLine(0);
				}
				else
					nextMessage.bVisible = false;

				LineOffset += nextMessage.GetNumLines();
			}
		}

		if(TotalLines < maxDisplayableLines)
		{
			for(i = 0; i < maxDisplayableLines - TotalLines; ++i)
				Padding $= " ¼";
			PaddingMessage.SetText(MessageStyles[EMessageType.MessageType_Global], Padding);
			PaddingMessage.bVisible = true;
		}
		else
		{
			PaddingMessage.bVisible = false;
		}

		// relayout to push any remaining labels up into the new space
		super.DoLayout(c);
	}
}

defaultproperties
{
	MaxDisplayableLines=6
	MessageFadeDuration=0.7
	SecondsPerWord=0.75
	MinimumLifetime=5

	MessageStyles(0)="GlobalMessage"
	MessageStyles(1)="AllyMessage"
	MessageStyles(2)="EnemyMessage"
	MessageStyles(3)="SubtitleMessage"
	MessageStyles(4)="SystemMessage"
	MessageStyles(5)="StatHighMessage"
	MessageStyles(6)="StatMediumMessage"
	MessageStyles(7)="StatLowMessage"
	MessageStyles(8)="StatPenaltyMessage"
}