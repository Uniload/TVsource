class HUDTextMessage extends HUDMessage;

var private LabelElement textLabel;

// Gets the text of the message, not necesarily valid
function String GetText()
{
	return textLabel.GetText();
}

// Sets the text of the message
function SetText(String LabelTemplateName, String newText)
{
	if(textLabel == None)
	{
		textLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", LabelTemplateName));
		textLabel.bHTMLEncoded = true;
		textLabel.bRelativePositioning = true;
		textLabel.bAutoSize = false;
	}

	textLabel.SetText(newText);
}

function int GetLineHeight(Canvas canvas)
{
	local float XL, YL;
	local Font oldFont;

	if(textLabel != None)
	{
		oldFont = canvas.Font;

		canvas.Font = textLabel.textFont;
		canvas.StrLen( "W", XL, YL );
		canvas.Font = oldFont;

		return int(YL);
	}

	return super.GetLineHeight(canvas);
}

// Sets the colour of the message
function SetTextColor(Color c)
{
	textLabel.textColor = c;
}

// gets the number of lines in the message
function int GetNumLines()
{
	return textLabel.textLineArray.Length;
}

// Sets the first visible line of the message
function SetFirstVisibleLine(int newFirstVisibleLine)
{
	super.SetFirstVisibleLine(newFirstVisibleLine);
	textLabel.firstVisibleLineIndex = newFirstVisibleLine;
}
