class TribesTurretHUD extends TribesInGameHUD;

simulated function UpdateHUDData()
{
	local Turret occupiedTurret;
	local Weapon usedWeapon;

	super.UpdateHUDData();

	ClearHUDEquipmentData();

	if(Turret(Controller.Pawn) != None)
	{
		// we are in a ground turret
		occupiedTurret = Turret(Controller.Pawn);
		usedWeapon = Turret(Controller.Pawn).weapon;

		clientSideChar.turretHealth = occupiedTurret.health;
		clientSideChar.turretHealthMaximum = occupiedTurret.healthMaximum;

		clientSideChar.activeWeapon.type = usedWeapon.class;
		clientSideChar.activeWeapon.ammo = usedWeapon.ammoCount;
		clientSideChar.activeWeapon.bCanFire = usedWeapon.canFire();
		clientSideChar.activeWeapon.refireTime = 1.0 / usedWeapon.roundsPerSecond;
		clientSideChar.activeWeapon.timeSinceLastFire = Level.TimeSeconds - usedWeapon.lastFireTime;
	}

}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesTurretHUDScript"
	HUDScriptName = "default_TurretHUD"
}