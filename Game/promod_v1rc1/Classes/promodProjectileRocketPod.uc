class promodProjectileRocketPod extends EquipmentClasses.ProjectileRocketPod config(promod);

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
         {
	  super.ProjectileTouch(Other, TouchLocation, TouchNormal);
         }

defaultproperties
{
damageAmt=20.000000
}
