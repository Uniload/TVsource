class x2ProjectileBlaster extends EquipmentClasses.ProjectileBlaster;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     Skins(0)=Shader'weapons.bulletblastershader'
}
