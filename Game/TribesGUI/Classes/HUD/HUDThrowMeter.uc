///
///
///
class HUDThrowMeter extends HUDValueBar;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	value = c.throwForce;
	maximumValue = c.throwForceMax;

	activeFullTexture.fadeProgress = ratio;

	bVisible = (value > 0);
}

defaultproperties
{
	emptyTexture=(Material=Texture'HUD.ReticuleChargeEmpty',drawColor=(R=255,G=255,B=255,A=255),style=1)
	fullTexture=(Material=Texture'HUD.ReticuleChargeFull',drawColor=(R=255,G=0,B=0,A=255),bFading=true,bProgressControlled=true,fadeSourceColor=(R=255,G=255,B=0,A=255),fadeTargetColor=(R=255,G=0,B=0,A=255),style=1)
	barStartOffset=38
	barEndOffset=38
}