class ExtendedStat extends Stat;

var()	int		minTargetAltitude;
var()	float	minTargetSpeed;
var()	float	maxTargetSpeed;
var()	int		minDistance;
var()	int		maxDistance;
var()	float	minDamage;
var()	bool	bAllowTargetInVehicleOrTurret;

// Some other parameters that could be implemented.
// To do this properly, you'd have to take a snapshot of the source's relevant movement stats
// at the time the projectile was fired, otherwise it wouldn't be entirely accurate (especially
// for slow-moving projectiles).  That would be a lot of effort though.
//var()	int		minSourceAltitude;
//var()	int		minTargetAltitudeRelative;
//var()	float	minSourceSpeed;
//var()	float	minTargetSpeedRelative;
//var()	int		maxSourceAltitude;
//var()	int		maxTargetAltitude;
//var()	int		maxTargetAltitudeRelative;
//var()	float	maxSourceSpeed;
//var()	float	maxTargetSpeedRelative;

static function bool isEligible(Controller Source, Controller Target, float damageAmount)
{
	local vector hitLocation, hitNormal, startTrace, endTrace;
	local int relativeDistance;
	local Character targetCharacter;
	local PlayerCharacterController pcc;

	if (Target == None || Source == None)
		return false;

	// Damage check, but only if target is alive
	if (Target.Pawn.IsAlive() && damageAmount < default.minDamage)
		return false;

	// Vehicle/turret check
	pcc = PlayerCharacterController(Target);
	if (!default.bAllowTargetInVehicleOrTurret && pcc != None && !pcc.IsInState('CharacterMovement'))
		return false;

	// Minimum distance check
	relativeDistance = VSize(Source.Pawn.Location - Target.Pawn.Location);
	if (relativeDistance < default.minDistance)
		return false;

	// Maximum distance check
	if (default.maxDistance != 0 && relativeDistance >= default.maxDistance)
		return false;

	// Minimum target altitude check
	startTrace = Target.Pawn.Location;
	endTrace = Target.Pawn.Location;
	endTrace.z -= default.minTargetAltitude;
	if (Target.Trace(hitLocation, hitNormal, endTrace, startTrace) != None)
		return false;

	// Minimum target speed check
	targetCharacter = Character(Target.Pawn);
	if (targetCharacter.movementSpeed < default.minTargetSpeed)
		return false;

	// Maximum target speed check
	if (default.maxTargetSpeed != 0 && targetCharacter.movementSpeed >= default.maxTargetSpeed)
		return false;

	// If this point is reached, all tests passed and the stat is awarded
	return true;
}

defaultproperties
{
}