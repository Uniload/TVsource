class HUDMessageWindow extends HUDMessagePane;

// number of messages in the window right now
var int NumMessages;
var int ForcedMaxVisibleLines;

function InitElement()
{
	super.InitElement();

	RemoveAll();
	NumMessages = 0;
}

function GetNewMessages(ClientSideCharacter c)
{
	local HUDTextMessage newMessage;
	local int i;

	// take care of the case when there are more messages
	// in the children list than there are on the csc list
	if(c.Messages.Length < NumMessages)
	{
		for(i = 0; i < NumMessages - c.Messages.Length; ++i)
		{
			MessagePool.FreeObject(Children[i]);
			RemoveElementAt(i);
		}
		NumMessages = children.Length;
	}

	// add all the messages
	while(NumMessages < c.messages.Length)
	{
		newMessage = HUDTextMessage(MessagePool.AllocateObject(class'HUDTextMessage'));
		newMessage.SetText(MessageStyles[c.messages[NumMessages].Type], c.messages[NumMessages].Text);

		AddMessage(newMessage);

		NumMessages++;
	}
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	bVisible = c.bDisplayChatWindow;

	if(! bVisible)
		return;

	if(ForcedMaxVisibleLines < 0)
	{
		if(MaxDisplayableLines != c.CurrentChatWindowSize)
		{
			MaxDisplayableLines = c.CurrentChatWindowSize;
			ScrollMessages(0);
		}
	}
	else if(MaxDisplayableLines != ForcedMaxVisibleLines)
	{
		MaxDisplayableLines = ForcedMaxVisibleLines;
		ScrollMessages(0);
	}

	if(c.ChatScrollDelta != 0)
	{
		ScrollMessages(c.ChatScrollDelta);
		c.ChatScrollDelta = 0;
	}
}

defaultproperties
{
	ForcedMaxVisibleLines = -1;
	bScrollable=true
	bAutoHeight=true
}