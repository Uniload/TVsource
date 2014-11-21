class TsActionAttachToActor extends TsAction;

var(Action)		MojoActorRef		Target;
var(Action)		Vector				RelativeLocation;
var(Action)		Rotator				RelativeRotation;
var(Action)		Name				AttachmentBone;

function bool OnStart()
{
	local Engine.Pawn P;

	Target = ResolveActorRef(Target);
	if (Target.actor == None)
		Log("TsActionAttachToActor, Failed to find target actor "$Target.name);

	// unattach attaching actor
	Target.actor.SetBase(None);

	// attach actor to ourselves
	if (AttachmentBone != '')
	{
		P = Engine.Pawn(Actor);
		if (P == None)
		{
			Log("TsActionAttachToActor, actor requesting bone attachment is not a pawn, "$Actor.Name);
			return false;
		}

		P.AttachToBone(Target.Actor, AttachmentBone);
	}
	else
	{
		Target.Actor.SetLocation(Actor.Location);
		Target.Actor.SetBase(Actor);
	}

	Target.Actor.SetRelativeLocation(RelativeLocation);
	Target.Actor.SetRelativeRotation(RelativeRotation);

	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Attach To Actor"
	Track			="Effects"
	Help			="Attach an actor to the owner of a track, i.e. particle systems."
}

