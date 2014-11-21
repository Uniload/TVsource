//=============================================================================
// Event.
//=============================================================================
class Triggers extends Actor
	abstract
	placeable
	native;

// IGA >>> stuff needed for triggering mojo scenes
var(MOJO) bool	trigger_cutscene;
var(MOJO) name	cutscene_name;

native function TriggerMojoCutscene(name cutscene_name);

event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	// trigger cutscene specified.. call into mojo
	if (trigger_cutscene)
	{
		// EventInstigator.Instigator.ClientMessage("Triggered mojo cutscene");
		TriggerMojoCutscene(cutscene_name);
	}

	// normal trigger event
	super.TriggerEvent(EventName,Other,EventInstigator);
}
// IGA

defaultproperties
{
     bHidden=True
     CollisionRadius=+00040.000000
     CollisionHeight=+00040.000000
     bCollideActors=True
}
