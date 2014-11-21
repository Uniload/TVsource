class HUDEventMessage extends HUDMessage;

var LabelElement LabelOne;
var LabelElement LabelTwo;
var HUDIcon Icon;

function Initialise(String StringOne, String TemplateOneName, 
					String StringTwo, String TemplateTwoName, 
					HUDMaterial IconMaterial, int IconWidth, int IconHeight)
{
	if(LabelOne == None)
	{
		LabelOne = LabelElement(AddClonedElement("TribesGUI.LabelElement", TemplateOneName));
		LabelOne.bAutoWrapText = false;
		LabelOne.bAutoSize = true;
		LabelOne.bHTMLEncoded = true;
		LabelOne.horizontalAlignment=HALIGN_Previous;
	}

	if(Icon == None)
	{
		Icon = HUDIcon(AddElement("TribesGUI.HUDIcon"));
		Icon.FixedIconWidth = IconWidth;
		Icon.FixedIconHeight = IconHeight;
		Icon.Width = IconWidth;
		Icon.Height = IconHeight;
		Icon.horizontalAlignment=HALIGN_Previous;
	}

	if(LabelTwo == None)
	{
		LabelTwo = LabelElement(AddClonedElement("TribesGUI.LabelElement", TemplateTwoName));
		LabelTwo.bAutoWrapText = false;
		LabelTwo.bAutoSize = true;
		LabelTwo.bHTMLEncoded = true;
		LabelTwo.horizontalAlignment=HALIGN_Previous;
	}

	LabelOne.SetText(StringOne);
	LabelTwo.SetText(StringTwo);
	Icon.IconMaterial = IconMaterial;
}

function int GetLineHeight(Canvas canvas)
{
	if(Icon == None)
		return Icon.FixedIconHeight;

	else return 8;
}
