class TsMojoAction extends Core.Object
	abstract native;

import class Engine.Actor;

// The Actor object we are manipulating. This member is set by the native framework
var const transient actor Actor;

///////////////////////////////////////////////////////////////////////////////////////////////////////
// noexport vars (declared in UTsMojoAction.h). Must go after UC vars, and the sizeof this var block 
// must match the sizeof vars added in the C++ header
//
//	NOTE: bool defs must NOT be placed sequentially, or else uscript will pack them into a single 4 byte
//	block, causing the uscript class size to mismatch the C++ defs
///////////////////////////////////////////////////////////////////////////////////////////////////////
var const transient private noexport bool	m_skip_action;	
var const transient private noexport Object m_source_key;
var const transient private noexport Object m_output_key;
var const transient private noexport Object m_group;
var const transient private noexport float m_start_time;
var const transient private noexport float m_offset;	
var const transient private noexport float m_predicted_start_time;
var const transient private noexport float m_recorded_length;
var const transient private noexport bool	m_length_dirty;
var const transient private noexport Array<TsMojoAction> m_subaction_list;
var const transient private noexport float m_subaction_offset;
var const transient private noexport TsMojoAction m_subaction_parent;
var const transient private noexport int m_subaction_track;
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Extended property defs
// ---------------------------------------------------------------------------------------------------
// These properties are scanned for by the mojo tool, and when found, an extended editing interface is
// exposed
///////////////////////////////////////////////////////////////////////////////////////////////////////
struct native MojoKeyframe
{
	var() vector	position;
	var() rotator	rotation;
};

struct native MojoTimedKeyframe
{
	var() vector	position;
	var() rotator	rotation;
	var() float		time;
};

struct native MojoAnimation
{
	var() name	name;
	var() name	animation_set;
};

struct native MojoActorRef
{
	var() name	name;
	var transient Actor actor;
};

function final MojoActorRef ResolveActorRef(MojoActorRef ref)
{
	local Actor find_actor;

	ref.actor = None;
	ForEach Actor.AllActors(class'Actor', find_actor)
	{
		if (find_actor.name == ref.name)
		{
			ref.actor = find_actor;
			break;
		}
	}

	return ref;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Base interface
///////////////////////////////////////////////////////////////////////////////////////////////////////
event bool Start();
event bool Tick(float delta);
event Finish();
event bool EndCutscene()
{
	return false;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Editor Interface
///////////////////////////////////////////////////////////////////////////////////////////////////////
// we provide some default strings, or else the event calls will fail on FindFunctionChecked
event string GetNameString()	{ return "action"; }
event string GetTrackString()	{ return "track"; }
event string GetHelpString()	{ return "help me, i'm a fish"; }
event string GetSummaryString()	{ return "nothing"; }

// used to filter actions so that not all actions appear on all actors
event bool CanBeUsedWith(Actor actor)
{
	return true;
}

// used to find actions that can be skipped during fastforward
event bool CanFastForwardSkip()
{
	return false;
}

// indicates we can set the actions duration directly
event bool CanSetDuration()
{
	return false;
}

// can be used to determine if an action will move an actor
event bool ModifiesActorLocation()
{
	return false;
}

// indicates the action should not play in mojo (eg for change level actions)
event bool DisableActionInMojo()
{
	return false;
}

// indicates the action is a subaction, to be kept in lockstep with some other action
event bool IsSubaction()
{
	return false;
}

// indicates that the action can accept subactions
event bool CanAcceptSubactions()
{
	return true;
}

// indicates that output keys can be created from this action
event bool CanGenerateOutputKeys()
{
	return true;
}

// OnDelete
// Called by the mojo UI when it deletes the action
event OnDelete()
{
}

event Interrupt()	{}
event Pause()		{}
event Resume()		{}
event bool SetDuration(float duration) { return false; }
event float GetDuration() { return -1; }
///////////////////////////////////////////////////////////////////////////////////////////////////////

defaultproperties
{
}
