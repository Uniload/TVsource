//=====================================================================
// IWeaponSelectionFunction
//
// Defines a function for selecting the best weapon for a given AI
// and situation
//=====================================================================

interface IWeaponSelectionFunction;

//=====================================================================
// Functions

// weapon to use in the current circumstance
function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass );

// best range at which to shoot weapon
function float firingRange( class<Weapon> weaponClass );

// are conditions met for firing this weapon?
function bool bShouldFire( BaseAICharacter ai, Weapon weapon );


