class HUDEventMessageWindow extends HUDMessagePane;

var() config HUDMaterial IconMaterial;
var() config int IconWidth;
var() config int IconHeight;

function GetNewMessages(ClientSideCharacter c)
{
	local int i;
	local HUDEventMessage newMessage;

	// Don't display any event messages in single player
	if (ClassIsChildOf(c.GameClass, class'SinglePlayerGameInfo'))
		return;

	// add all the messages
	for(i = 0; i < c.EventMessages.Length; ++i)
	{
		newMessage = HUDEventMessage(MessagePool.AllocateObject(class'HUDEventMessage'));

		IconMaterial.Material = c.EventMessages[i].IconMaterial;
		newMessage.Initialise(c.EventMessages[i].StringOne, MessageStyles[c.EventMessages[i].StringOneType],
							  c.EventMessages[i].StringTwo, MessageStyles[c.EventMessages[i].StringTwoType],
							  IconMaterial, IconWidth, IconHeight);

		AddMessage(newMessage);
	}

	c.EventMessages.Remove(0, c.EventMessages.Length);
}

defaultproperties
{
	IconMaterial=(drawColor=(R=255,G=255,B=255,A=255),style=1)
	IconWidth=45
	IconHeight=20

	MaxMessages=5
	SecondsPerWord=0.0
}