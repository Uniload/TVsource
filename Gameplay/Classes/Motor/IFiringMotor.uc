interface IFiringMotor;

// setViewRotation
function setViewRotation(Rotator r);

// getViewRotation
function Rotator getViewRotation();

// If this function returns true then the aiming rotation is based directly on the players view otherwise getViewRotation is used.
function bool aimAdjustViewRotation();

// fire
function fire(optional bool fireOnce);

// altFire
function altFire(optional bool fireOnce);

// releaseFire
function releaseFire();

// releaseAltFire
function releaseAltFire();

function bool shouldFire(Equippable e);

function setFirePressed(Equippable e, bool pressed);

function vector getProjectileSpawnLocation();

function onShotFiredNotification();

// It is assumed that a class that implements the IFiringMotor has some form of energy concept.
function float getEnergy();

// It is assumed that a class that implements the IFiringMotor has some form of energy concept.
function useEnergy(float energyUsage);

simulated function vector getFirstPersonEquippableLocation(Equippable subject);

simulated function rotator getFirstPersonEquippableRotation(Equippable subject);

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName);

// returns the rook the weapon is attached to: character for character weapons, turrets for turret weapons, and vehicle for weapons attached to a vehicle
function Rook getPhysicalAttachment();

function Weapon getWeapon();

// Returns the Actor that effects should be triggered on. None implies the weapon itself should be used.
simulated function Actor getEffectsBaseActor();

simulated function bool customFiredEffectProcessing();

simulated function doCustomFiredEffectProcessing();

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart);