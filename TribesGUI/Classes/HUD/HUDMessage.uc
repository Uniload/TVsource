
class HUDMessage extends HUDContainer;

// when marked as irrelevant, the message will fade out to
// be invisible and eventually be removed from the list entirely
var private bool bIrrelevant;

var float AppearTime;		// Time at which the message appeared
var float Lifetime;			// lifetime of the message, -1 for infinite
var float TimeOfDeath;		// time the message became irrelevant
var float FadeOutDuration;	// how long the message will take to fade away

var int	firstVisibleLine;	// first visible line

// Gets the text of the message, not necesarily valid
function String GetText()
{
	return "";
}

// gets the number of lines in the message
function int GetNumLines()
{
	return 1;
}

//
// Only valid if all messages usethe same font.
//
// The only place this function is currently used is for the chat
// window in the end game mp menu.
//
function int GetLineHeight(Canvas canvas)
{
	// just a default, subclasses will need to override
	return 8;
}

// Sets the first visible line of the message
function SetFirstVisibleLine(int newFirstVisibleLine)
{
	firstVisibleLine = newFirstVisibleLine;
}

function Reset()
{
	bVisible = true;
	SetAlpha(1.0);
	bIrrelevant = false;
	timeOfDeath = 0;
}

// Marks the message as irrelvant and sets its time of death
function MarkAsIrrelevant()
{
	bIrrelevant = true;
	timeOfDeath = TimeSeconds;
}

//
// Updates visibility of the message:
// * Lifetimes are checked constantly until the message is marked irrelvant
// * Irrelvant messages have their alpha reduced to 0 and are then marked invisible
//
function UpdateVisibility()
{
	// if already invisible or infinite lifetime, then return
	if(! bVisible || Lifetime <= 0)
		return;

	if(Lifetime < (TimeSeconds - AppearTime) && ! bIrrelevant)
		MarkAsIrrelevant();

	// irrelevant message - fade it out
	if(bIrrelevant)
	{
		// degrade the alpha value
		SetAlpha(FClamp(1.0 - ((TimeSeconds - TimeOfDeath) / FadeOutDuration), 0.0, 1.0));

		if(GetAlpha() == 0)
			bVisible = false;
	}
}

defaultproperties
{

}