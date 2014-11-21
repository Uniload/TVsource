class HUDPersonalMessageWindow extends HUDMessagePane;

function GetNewMessages(ClientSideCharacter c)
{
	local int i;
	local HUDTextMessage newMessage;

	// Don't display any personal messages in single player
	if (ClassIsChildOf(c.GameClass, class'SinglePlayerGameInfo'))
		return;

	// add all the messages
	for(i = 0; i < c.PersonalMessages.Length; ++i)
	{
		newMessage = HUDTextMessage(CreateHUDElement(class'HUDTextMessage', ""));
		newMessage.SetText(MessageStyles[c.PersonalMessages[i].Type], c.PersonalMessages[i].Text);

		AddMessage(newMessage);
	}

	c.PersonalMessages.Remove(0, c.PersonalMessages.Length);
}

defaultproperties
{
	MaxMessages=3
	MessageLifetime=5
	SecondsPerWord=0.0
}