class ChargeUpWeapon extends Weapon
	abstract;

var float charge;
var() float maxCharge;
var() float chargeScale;
var() bool bShowChargeOnHUD			"Whether the charge level should be shown on the hud when the user charges the weapon";

simulated state FirePressed
{
	simulated function BeginState()
	{
		charge = 0.0;
		super.BeginState();
	}
}

defaultproperties
{
}
