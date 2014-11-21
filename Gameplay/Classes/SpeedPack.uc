class SpeedPack extends Pack;

var (SpeedPack) float refireRateScale		"How much to scale the refire rate of all weapons when the pack is active";
var (SpeedPack) float passiveRefireRateScale "How much to scale the refire rate of all weapons when the pack is worn";
var (SpeedPack) Material passiveMaterial	"Overlay material, if any, to be used when pack is passive";
var (SpeedPack) Material activeMaterial		"Overlay material, if any, to be used when pack is active";
var Character user;
var bool bWarned;

var Material currentOverlay;

simulated function applyPassiveEffect(Character characterOwner)
{
	user = characterOwner;

	currentOverlay = passiveMaterial;

	scaleRefireRate(passiveRefireRateScale);
}

simulated function removePassiveEffect(Character characterOwner)
{
	resetRefireRate();
}

simulated function startActiveEffect(Character characterOwner)
{
	currentOverlay = activeMaterial;

	scaleRefireRate(refireRateScale);

	user.TriggerEffectEvent('SpeedPackActive',,,,,,,self);
}

simulated function finishActiveEffect()
{
	resetRefireRate();

	applyPassiveEffect(user);

	user.UnTriggerEffectEvent('SpeedPackActive');
}

simulated function scaleRefireRate(float scale)
{
	local Equipment e;
	local Weapon w;

	e = user.equipmentHead();

	// Scale up weapon refire rates
	while (e != None)
	{
		w = Weapon(e);

		if (w != None)
			w.addSpeedPackScale(scale);

		e = e.next;
	}

	if (user.fallbackWeapon == None)
		user.spawnFallbackWeapon();

	if (user.fallbackWeapon != None)
		user.fallbackWeapon.addSpeedPackScale(scale);
}

simulated function resetRefireRate()
{
	local Equipment e;
	local Weapon w;

	e = user.equipmentHead();
	// Reset weapon refire rates
	while (e != None)
	{
		w = Weapon(e);

		if (w != None)
			w.removeSpeedPackScale();

		e = e.next;
	}

	if (user.fallbackWeapon == None)
		user.spawnFallbackWeapon();

	if (user.fallbackWeapon != None)
		user.fallbackWeapon.removeSpeedPackScale();
}

simulated event Material GetOverlayMaterialForOwner(int Index)
{
	return currentOverlay;
}

simulated function OnEffectStarted(Actor inStartedEffect)
{
	local Emitter e;
	local int i;

	e = Emitter(inStartedEffect);

	if (e != None)
	{
		for (i = 0; i < e.Emitters.Length; i++)
		{
			e.Emitters[i].SkeletalMeshActor = user;
		}
	}
	else
		super.OnEffectStarted(inStartedEffect);
}

defaultproperties
{
     refireRateScale=2.000000
     passiveRefireRateScale=1.300000
     passiveMaterial=Texture'BaseObjects.ResupplyStationLum'
     activeMaterial=Texture'BaseObjects.ResupplyStationLum'
     rechargeTimeSeconds=10.000000
     rampUpTimeSeconds=0.000000
     durationSeconds=5.000000
     thirdPersonMesh=StaticMesh'packs.CloakPack'
     cannnotBeUsedWhileTouchingInventoryStation=True
     StaticMesh=StaticMesh'packs.CloakPackdropped'
}
