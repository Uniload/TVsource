class CharacterMotor extends Motor implements IFiringMotor
	native;

import enum GroundMovementLevels from Character;

var Character			character;
var Name				switchingToState;
var Weapon				switchToWeapon;
var Weapon				lastUsedWeapon;
var Deployable			switchToDeployable;
var float				unequipDuration;
var bool				bFirePressed;

// construct
overloaded simulated function construct( actor Owner, optional optional name Tag, 
										  optional vector Location, optional rotator Rotation)
{
	Super.construct(Owner, Tag, Location, Rotation);

	character = Character(Owner);
	if (character == None)
	{
		LOG("ERROR: CharacterMotor's owner is not a pawn");
	}
}

// moveCharacter
native function moveCharacter(optional float forward, optional float strafe, optional float jump,
							  optional float ski, optional float thrust, optional GroundMovementLevels groundMovementLevel);

// setMoveRotation
native function setMoveRotation(Rotator r);

// setAIMoveRotation
// Temporary function for AI's which sets desiredRotation, not rotation directly
// As soon as Fusion handles ticked rotations this function becomes redundant
native function setAIMoveRotation(Rotator r);

// setViewRotation
native function setViewRotation(Rotator r);

// getMoveRotation
native function Rotator getMoveRotation();

// getMoveYawDelta
native function int getMoveYawDelta();

// getViewRotation
native function Rotator getViewRotation();

function bool aimAdjustViewRotation()
{
	return true;
}

// fire
native function fire(optional bool fireOnce);

// altFire
native function altFire(optional bool fireOnce);

// releaseAltFire
native function releaseAltFire();

// releaseFire
native function releaseFire();

function bool shouldFire(Equippable e)
{
	return bFirePressed && Character.weapon == e;
}

function setFirePressed(Equippable e, bool pressed)
{
	if (Character.weapon == e)
		bFirePressed = pressed;
}

function bool canUnequip()
{
	if (character.weapon != None)
		return character.weapon.canUnequip();
	
	if (character.deployable != None)
		return character.deployable.canUnequip();

	return true;
}

// setWeapon
event bool setWeapon(Weapon w)
{
	if (canUnequip() && (w == None || (w != character.weapon && w != switchToWeapon)))
	{
		lastUsedWeapon = w;
		switchToWeapon = w;
		switchingToState = 'SwitchingToWeapon';
		GotoState('SwitchingEquippables');
		return true;
	}

	return false;
}

// setDeployable
event bool setDeployable(Deployable d)
{
	if (canUnequip())
	{
		lastUsedWeapon = character.weapon;
		switchToDeployable = d;
		switchingToState = 'SwitchingToDeployable';
		GotoState('SwitchingEquippables');
		return true;
	}

	return false;
}

state SwitchingEquippables
{
begin:
	if (character.deployable != None)
	{
		unequipDuration = character.deployable.unequipDuration;
		character.deployable.unEquip();
		character.deployable = None;
	}

	if (character.weapon != None)
	{
		unequipDuration = character.weapon.unequipDuration;
		character.weapon.unEquip();
		character.weapon = None;
	}

	Sleep(unequipDuration);

	GotoState(switchingToState);
}

state SwitchingToWeapon
{
	function BeginState()
	{
		if (switchToWeapon != None)
		{
			switchToWeapon.equip();
			character.weapon = switchToWeapon;
		}
	}

begin:
	if (character.weapon != None)
		Sleep(character.weapon.equipDuration);

	switchToWeapon = None;
}

state SwitchingToDeployable
{
	function BeginState()
	{
		if (switchToDeployable != None)
		{
			switchToDeployable.equip();
			character.deployable = switchToDeployable;
		}
	}

begin:
	if (character.weapon != None)
		Sleep(character.deployable.equipDuration);

	switchToDeployable = None;
}

// setZoomed
event setZoomed(bool bZoomed)
{
	character.setZoomed(bZoomed);
}

simulated function vector getProjectileSpawnLocation()
{
	if (character.weapon == None)
	{
		warn("attempted to get projectile spawn location from character with no weapon");
		return character.location;
	}

	return character.weapon.calcProjectileSpawnLocation(getViewRotation());
}

function useEnergy(float amount)
{
	character.useEnergy(amount);
}

function float getEnergy()
{
	return character.energy;
}

function onShotFiredNotification()
{
	// ignore
}

simulated function vector getFirstPersonEquippableLocation(Equippable subject)
{
	local Vector v;
	local Rotator r;
	local Actor a;
	
	local PlayerController characterPlayerController;
	local PlayerController localPlayerController;
	local DemoController demoController;

	local bool bStoredBehindView;

	if (character.controller == None)
		return character.Location;

	characterPlayerController = PlayerController(character.controller);
	localPlayerController = Level.GetLocalPlayerController();
    demoController = DemoController(localPlayerController);	
	
	if ((characterPlayerController!=None && characterPlayerController==localPlayerController && demoController==None) ||
        (demoController!=None && demoController.ViewTarget==character))
    {
	    // players

		// Always calculate weapon location from first person
		bStoredBehindView = localPlayerController.bBehindView;
		localPlayerController.bBehindView = false;

		localPlayerController.PlayerCalcView(a, v, r);

		localPlayerController.bBehindView = bStoredBehindView;

		v += subject.getFirstPersonOffset() >> r;
		v -= (character.WalkBob * subject.firstPersonBobMultiplier);
	}
	else
	{
	    // ais
	
		v = character.Location + (subject.getFirstPersonOffset() >> character.controller.GetViewRotation()) + (character.WalkBob * (1.0 - subject.firstPersonBobMultiplier));
		v.Z += character.EyeHeight;
	}

	return v;
}

simulated function rotator getFirstPersonEquippableRotation(Equippable subject)
{
    local PlayerController characterPlayerController;
	local PlayerController localPlayerController;
	local DemoController demoController;

	characterPlayerController = PlayerController(character.controller);
	localPlayerController = Level.GetLocalPlayerController();
    demoController = DemoController(localPlayerController);	

	if (characterPlayerController == None && demoController == None)
	{
		return Rot(0, 0, 0);
	}

	if (demoController!=None && demoController.ViewTarget==character)
    	return character.Controller.Rotation;
    else
    	return character.Controller.GetViewRotation();
}

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = character;
	boneName = subject.thirdPersonAttachmentBone;
}

function Rook getPhysicalAttachment()
{
	return character;
}

function Weapon getWeapon()
{
	return character.weapon;
}

simulated function Actor getEffectsBaseActor()
{
	return None;
}

simulated function bool customFiredEffectProcessing()
{
	return false;
}

simulated function doCustomFiredEffectProcessing()
{
	assert(false);
}

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart);