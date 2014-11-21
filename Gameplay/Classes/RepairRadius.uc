class RepairRadius extends Engine.Actor implements IEffectObserver
	native;

var IRepairClient rc;
var Array<Rook> touchingLOS;
var Actor currentTendrilTarget;
var Array<RepairTendril> tendrils;

// DO NOT CALL THIS OUTSIDE THE CONSTRUCTOR
native final function SetRepairRadius(int NewRepairRadius);

overloaded function Construct( actor Owner, optional name Tag, optional vector Location, optional rotator Rotation)
{
	local float radius;

	assert(IRepairClient(Owner) != None);
	rc = IRepairClient(Owner);

	radius = rc.getRepairRadius();
	
	SetRepairRadius(radius);

	super.Construct(Owner, Tag, Location, Rotation);
}

function Destroyed()
{
	local Rook r;
	local int i;

	// safeguard
	if (Owner == None || rc == None)
	{
		Destroy();
		return;
	}

	for (i = 0; i < Touching.Length; ++i)
	{
		r = Rook(Touching[i]);

		if (r != None)
		{
			removeTouchingLOS(r);
		}
	}

	// stop FX
	for (i = 0; i < tendrils.Length; i++)
	{
		tendrils[tendrils.Length].system.Kill();
		tendrils[tendrils.Length].Delete();
	}

	tendrils.Length = 0;
}

function Tick(float Delta)
{
	local Rook r;
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{
		r = Rook(Touching[i]);

		if (r != None)
		{
			if (rc.canRepair(r) && FastTrace(r.Location))
				addTouchingLOS(r);
			else
				removeTouchingLOS(r);
		}
	}

	// update fx
	i = 0;
	while (i < tendrils.Length)
	{
		if (tendrils[i].target == None)
		{
			destroyTendrilByIdx(i);
		}
		else
		{
			tendrils[i].update();
			i++;
		}
	}
}

function UnTouch(Actor Other)
{
	if (Rook(Other) != None)
		removeTouchingLOS(Rook(Other));
}

function addTouchingLOS(Rook r)
{
	local int i;

	for (i = 0; i < touchingLOS.Length; ++i)
		if (touchingLOS[i] == r)
			return;

	if (touchingLOS.Length == 0)
	{
		rc.getFXOriginActor().UnTriggerEffectEvent('RepairPackStop');
		rc.getFXOriginActor().TriggerEffectEvent('RepairPackStart');
	}

	// add a tendril
	currentTendrilTarget = r;
	rc.getFXOriginActor().TriggerEffectEvent('RepairPackTendril',,,,,,,self);

	touchingLOS[touchingLOS.Length] = r;
	rc.beginRepair(r);
}

function removeTouchingLOS(Rook r)
{
	local int i;

	for (i = 0; i < touchingLOS.Length; ++i)
	{
		if (touchingLOS[i] == r)
		{
			touchingLOS.Remove(i, 1);
			rc.endRepair(r);

			// stop tendril FX
			destroyTendril(r);

			if (touchingLOS.Length == 0)
			{
				rc.getFXOriginActor().UnTriggerEffectEvent('RepairPackStart');
				rc.getFXOriginActor().TriggerEffectEvent('RepairPackStop');
			}

			break;
		}
	}
}

// FX
// Called whenever an effect is started.
function OnEffectStarted(Actor inStartedEffect)
{
	if (Emitter(inStartedEffect) != None)
		addTendril(currentTendrilTarget, Emitter(inStartedEffect));
}

function OnEffectStopped(Actor e, bool b)
{
}

function OnEffectInitialized(Actor inInitializedEffect)
{
}

function addTendril(Actor target, Emitter effect)
{
	local RepairTendril t;

	t = new(self) class'RepairTendril';

	t.system = effect;
	t.target = target;
	t.originator = rc.getFXOriginActor();
	t.client = rc;

	tendrils[tendrils.Length] = t;

	if (rc != None)
		rc.onTendrilCreate(t);
}

function destroyTendril(Actor target)
{
	local int i;

	for (i = 0; i < tendrils.Length; i++)
	{
		if (tendrils[i].target == target)
		{
			destroyTendrilByIdx(i);
			return;
		}
	}
}

function destroyTendrilByIdx(int idx)
{
	tendrils[idx].system.Kill();
	tendrils[idx].Delete();
	tendrils.Remove(idx, 1);
}

defaultproperties
{
     bHidden=True
     bOnlyAffectPawns=True
     RemoteRole=ROLE_None
     bCollideActors=True
}
