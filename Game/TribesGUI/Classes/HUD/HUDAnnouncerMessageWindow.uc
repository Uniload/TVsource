class HUDAnnouncerMessageWindow extends HUDMessagePane;

function InitElement()
{
	super.InitElement();
}

function GetNewMessages(ClientSideCharacter c)
{
	local int i;
	local HUDTextMessage newMessage;

	// add all the messages
	for(i = 0; i < c.Announcements.Length; ++i)
	{
		newMessage = HUDTextMessage(MessagePool.AllocateObject(class'HUDTextMessage'));
		newMessage.SetText(TemplateMessageLabelName, c.Announcements[i]);

		AddMessage(newMessage);
	}

	c.Announcements.Remove(0, c.Announcements.Length);
}

defaultproperties
{
	MaxMessages=3
	MessageLifetime=5
	SecondsPerWord=0.0
}