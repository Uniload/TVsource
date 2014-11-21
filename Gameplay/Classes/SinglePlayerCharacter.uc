class SingleplayerCharacter extends PlayerCharacter;

// setting to none implies no jetpack
var (SingleplayerCharacter) class<Jetpack> jetpackClass;
var (SingleplayerCharacter) Mesh armsMesh;
var (SingleplayerCharacter) float healthModifier;
var (SingleplayerCharacter) float loadoutAmmoMultiplier		"Weapons that the players are equipped with via loadouts have their ammo multiplied by this value";

function PostBeginPlay()
{
	super.PostBeginPlay();

	// spawn and attach jetpack if necessary
	if (jetpackClass != None)
	{
		setJetpack(Spawn(jetpackClass, self));
	}

	// set the arms mesh if necessary
	if (armsMesh != None)
	{
		setArmsMesh(armsMesh);
	}
}

function giveJetpack(class<Jetpack> jpClass)
{
	jetpackClass = jpClass;

	bDisableJetting = false;
	setJetpack(Spawn(jetpackClass, self));
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	healthMaximum *= healthModifier;
	health = healthMaximum;

	if (GameInfo(Level.Game) != None)
		GameInfo(Level.Game).modifyPlayer(self);
}

simulated function int getModifiedAmmo(int baseAmmo)
{
	if (baseAmmo == -1)
		return baseAmmo;
	else
		return baseAmmo * loadoutAmmoMultiplier;
}

defaultproperties
{
     jetpackClass=Class'jetpack'
     armsMesh=SkeletalMesh'weapons.PhoenixMediumFPH'
     healthModifier=1.000000
     loadoutAmmoMultiplier=1.000000
     loadoutClass=Class'TestLoadout'
     armorClass=Class'TestArmor'
     bCanZoom=True
}
