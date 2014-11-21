// Base class for all actions
class TsAction extends MojoCore.TsMojoAction
	abstract
	native
	hidecategories(Object)
	collapsecategories;

var string			DName;
var string			Track;
var string			Help;
var bool			FastForwardSkip;
var bool			ModifiesLocation;
var bool			DisableInMojo;
var bool			UsesDuration;

var private config bool	bShowSubtitles;

var transient float interpTime;
var const transient noexport int interpolator;	// alloc'd native interpolator class

//----------------------------------------------
// Inherit "On" functions to implement actions

// Called when action begins
//	return false to end action
function bool OnStart()
{
	return true;
}

// Called each frame
//	return false to end action
function bool OnTick(float delta)
{
	return false;
}

// Called when action ends
//	this will occur when OnTick() returns false
function OnFinish()
{
}

//----------------------------------------------
// Mojo query functions

// return the length of this action.  
// Default zero length for point actions
function float GetLength()
{
	return 0.0f;
}

// Derived classes return a summary string.  
// This can contain information based on attributes.
function string GetSummaryString()
{
	return DName;
}

//----------------------------------------------
// Event control, usually inherit "On" functions

// Event called when action begins
//	return false to end action
function bool Start()
{
	return OnStart();
}

// Event called each frame
//	return false to end action
function bool Tick(float delta)
{
	return OnTick(delta);
}

// Event called when action ends
//	this will occur when Tick() returns false
function Finish()
{
	OnFinish();
}

// Event called when a message is received from a MessageRouter
function Message(Message msg)
{
}

//---------------------------------------------------
// No need to derive these, since
// they query attributes
function string GetNameString()
{
	return DName;
}

function string GetTrackString()
{
	return Track;
}

function string GetHelpString()
{
	return Help;
}

event bool CanFastForwardSkip()
{
	return FastForwardSkip;
}

event bool CanSetDuration()
{
	return UsesDuration;
}

event bool ModifiesActorLocation()
{
	return ModifiesLocation;
}

event bool DisableActionInMojo()
{
	return DisableInMojo;
}

//-----------------------------------------------------------------------------
// resetInterpolation
//
// Resets the interpolation state of this action.
//-----------------------------------------------------------------------------
native function resetInterpolation(float easeIn, float duration, float easeOut);

//-----------------------------------------------------------------------------
// tickInterpolation
//
// Does interpolation processing for a particular tick. Returns false when
// interpolation is finished.
//-----------------------------------------------------------------------------
native function bool tickInterpolation(float delta, out float alpha);

native function bool ShouldShowSubtitles();

// Derived classes should override this attributes
defaultproperties
{
	DName		="<action>"
	Track		="<track>"
	Help		="Action abstract base class"

	FastForwardSkip = false
	ModifiesLocation = false
	DisableInMojo = false
	UsesDuration = false
	ShowSubtitles = false
}



