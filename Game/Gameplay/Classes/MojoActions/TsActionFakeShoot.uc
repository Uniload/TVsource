class TsActionFakeShoot extends MojoActions.TsAction;

var() class<Weapon>			WeaponClass				"The reference class for the spawned projectile";
var() class<Emitter>		WeaponFlareClass		"The weapon flare emitter used";
var() int					ShotgunAmount			"If not 0, then multiple projectiles are created in a shotgun effect";
var() float					ShotgunSpread			"The amount of spread in the shotgun blast";
var() Name					OriginBone				"The bone at which the projectile starts. If none, it starts at the actor's position";
var() bool					bHitWorld				"Whether the projectile collides with the world";
var() bool					bHitPlayers				"Whether the projectile collides with characters";
var() bool					bManualTargetPoint		"Set this to true to specify the target point of the projectile";
var() MojoKeyframe			TargetPoint				"If bManualTargetPoint is true, the projectile will fly towards this location";


function bool OnStart()
{
	local Rotator r;
	local Vector targetVec;
	local Projectile Projectile;
	local Vector origin;
	local Vector X,Y,Z;
	local float spread;
	local int i;
	local int num;

	if (OriginBone != '')
	{
		origin = Actor.GetBoneCoords(OriginBone).Origin;
	}
	else
	{
		origin = Actor.Location;
	}

	spread = shotgunSpread;
	num = shotgunAmount;
	if (num == 0)
	{
		num = 1;
		spread = 0;
	}

	for (i = 0; i < num; i++)
	{
		Projectile = new(Actor.Level) WeaponClass.default.projectileClass(Rook(Actor), '', origin);
		if (Projectile == None)
		{
			log("Couldn't construct projectile of type "$WeaponClass.default.projectileClass);
			return false;
		}

		// set projectile parameters
		Projectile.rookAttacker = Rook(Actor);
		Projectile.SetCollision(bHitPlayers, false, false);
		Projectile.bCollideWorld = bHitWorld;
		
		Projectile.makeHarmless();

		// set orientation
		if (!bManualTargetPoint)
		{
			if (OriginBone != '')
			{
				r = Actor.GetBoneRotation(OriginBone);
			}
			else
			{
				r = Actor.Rotation;
			}
		}
		else
		{
			targetVec = (TargetPoint.position - Projectile.Location);
			targetVec /= VSize(targetVec);
			r = Rotator(targetVec);
		}

		// apply spread
		GetAxes(r, X, Y, Z);
		Projectile.SetRotation(Rotator(Vector(r) + (spread * (FRand() - 0.5)) * X +
													(spread * (FRand() - 0.5)) * Y +
													(spread * (FRand() - 0.5)) * Z));

		Projectile.Velocity = Vector(Projectile.Rotation) * WeaponClass.default.projectileVelocity;
	}

	// spawn weapon flare
	if (WeaponFlareClass != None)
		Actor.AttachToBone(Actor.spawn(WeaponFlareClass), OriginBone);

	return true;
}

function bool OnTick(float delta)
{
	return false;
}


function bool CanGenerateOutputKeys()
{
	return false;
}


defaultproperties
{
	DName			="Fake Weapon Shoot"
	Track			="Effects"
	Help			="Spawn a faked projectile from the given bone"
	FastForwardSkip = true

	WeaponClass		=class'Spinfusor'
	OriginBone		="bip01 rhand"
	bHitWorld		=true
	bHitPlayers		=false

	shotgunSpread	=0.4
}