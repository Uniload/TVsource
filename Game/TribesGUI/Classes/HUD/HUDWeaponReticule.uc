
//
// class: HUDWeaponReticule
//
// Reticule for a weapon, also indicates when an enemy is damaged.
//
class HUDWeaponReticule extends HUDReticule;

var bool			bZoomed;
var bool			bOutOfAmmo;

// hit feedback
var() config float	reticuleHitFeedbackFlashTime;
var HUDMaterial		reticuleHitFeedbackMaterial;
var float			retHitWidth;
var float			retHitHeight;
var float			hitTime;

// no weapon reticule
var Material		NoWeaponReticuleMaterial;

// no ammo indicator
var() config HUDMaterial	NoAmmoIndicatorMaterial;

// spread info
var() config int	MaxSpreadSize;
var HUDMaterial		ReticuleTopLeft;
var HUDMaterial		ReticuleTopRight;
var HUDMaterial		ReticuleBottomLeft;
var HUDMaterial		ReticuleBottomRight;
var float			SpreadAmount;

// zoom info
var() config HUDMaterial	zoomBlurMaterial;
var() config HUDMaterial	zoomReticuleMaterial;
var() config int			zoomReticuleWidth;
var() config int			zoomReticuleHeight;
var() config int			zoomReticuleCenterX;
var() config int			zoomReticuleCenterY;

var LabelElement	zoomMagnificationLabel;


function InitElement()
{
	super.InitElement();

	reticuleMaterial = MakeHUDMaterial(None);
	
	zoomMagnificationLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_zoomMagnificationLabel"));
}

function UpdateReticule(ClientSideCharacter c)
{
	local int HalfRetSize;

	// deployable reticule active, dont show weapon reticule
	if(c.bDeployableActive && ! c.bZoomed)
	{
		bOutOfAmmo = false;
		bVisible = false;
		return;
	}

	bVisible = true;
	bZoomed = c.bZoomed;
	zoomMagnificationLabel.bVisible = bZoomed;

	if(c.activeWeapon.type == None)
	{
		// this is the no-weapon reticule
		reticuleMaterial.material = NoWeaponReticuleMaterial;
		retWidth = NoWeaponReticuleMaterial.GetUSize();
		retHeight = NoWeaponReticuleMaterial.GetVSize();
		hotspotX = retWidth * 0.5;
		hotspotY = retHeight * 0.5;
		bOutOfAmmo = false;

		return;
	}


	retWidth = c.activeWeapon.type.default.hudReticuleWidth;
	retHeight = c.activeWeapon.type.default.hudReticuleHeight;
	hotspotX = c.activeWeapon.type.default.hudReticuleCenterX;
	hotspotY = c.activeWeapon.type.default.hudReticuleCenterY;
	if(bZoomed)
	{
		zoomMagnificationLabel.SetText("x"@c.zoomMagnificationLevel);
	}
	else if(c.activeWeapon.type != None)
	{
		// general reticule stuff
		reticuleMaterial.material = c.activeWeapon.type.default.hudReticule;

		SpreadAmount = c.activeWeapon.Spread;
		if(SpreadAmount > 0)
		{
			HalfRetSize = Min(c.ActiveWeapon.type.default.hudReticule.GetUSize(), c.ActiveWeapon.type.default.hudReticule.GetVSize()) * 0.5;

			ReticuleTopLeft.Material = c.ActiveWeapon.type.default.hudReticule;
			ReticuleTopLeft.Coords.U = 0;
			ReticuleTopLeft.Coords.V = 0;
			ReticuleTopLeft.Coords.UL = HalfRetSize - 2;
			ReticuleTopLeft.Coords.VL = HalfRetSize - 2;
			ReticuleTopLeft.fadeProgress = SpreadAmount;

			ReticuleTopRight.Material = c.ActiveWeapon.type.default.hudReticule;
			ReticuleTopRight.Coords.U = HalfRetSize + 2;
			ReticuleTopRight.Coords.V = 0;
			ReticuleTopRight.Coords.UL = HalfRetSize - 2;
			ReticuleTopRight.Coords.VL = HalfRetSize - 2;
			ReticuleTopRight.fadeProgress = SpreadAmount;

			ReticuleBottomLeft.Material = c.ActiveWeapon.type.default.hudReticule;
			ReticuleBottomLeft.Coords.U = 0;
			ReticuleBottomLeft.Coords.V = HalfRetSize + 2;
			ReticuleBottomLeft.Coords.UL = HalfRetSize - 2;
			ReticuleBottomLeft.Coords.VL = HalfRetSize - 2;
			ReticuleBottomLeft.fadeProgress = SpreadAmount;

			ReticuleBottomRight.Material = c.ActiveWeapon.type.default.hudReticule;
			ReticuleBottomRight.Coords.U = HalfRetSize;
			ReticuleBottomRight.Coords.V = HalfRetSize;
			ReticuleBottomRight.Coords.UL = HalfRetSize;
			ReticuleBottomRight.Coords.VL = HalfRetSize;
			ReticuleBottomRight.fadeProgress = SpreadAmount;
		}
	}

	// hit indicator stuff
	retHitWidth = reticuleHitFeedbackMaterial.material.GetUSize() * retWidth / reticuleMaterial.material.GetUSize();
	retHitHeight = reticuleHitFeedbackMaterial.material.GetVSize() * retWidth / reticuleMaterial.material.GetUSize();

	if(c.bHitObject)
	{
		hitTime = timeSeconds;
		ResetHUDMaterial(reticuleHitFeedbackMaterial);
		c.bHitObject = false;
	}

	// show the out of ammo indicator even when zoomed
	if(c.activeWeapon.type != None)
	{
		bOutOfAmmo = (c.activeWeapon.type.default.ammoUsage > 0) && (c.activeWeapon.ammo <= 0);

		if(bOutOfAmmo && c.activeWeapon.refireTime > c.activeWeapon.timeSinceLastFire)
		{
			if(NoAmmoIndicatorMaterial.fadeProgress == 1.0)
			{
				ResetHUDMaterial(NoAmmoIndicatorMaterial);
				NoAmmoIndicatorMaterial.fadeDuration = c.activeWeapon.refireTime;
			}
		}
	}
}

function RenderElement(Canvas c)
{
	local int ReticuleSize, HalfReticuleSize, CurrentSpreadSize;
	local int ReticuleX, ReticuleY;

	ReticuleX = ((Width - retWidth) / 2) + ((retWidth / 2) - HotspotX);
	ReticuleY = ((Height - retHeight) / 2) + ((retHeight / 2) - HotspotY);
	ReticuleSize = Min(retWidth, retHeight);

	if(bZoomed)
	{
		c.CurX = 0;
		c.CurY = 0;
		RenderHUDMaterial(c, zoomBlurMaterial, screenWidth, screenHeight);

		c.CurX = ((Width - retWidth) / 2) + ((retWidth / 2) - zoomReticuleCenterX);
		c.CurY = ((Height - retHeight) / 2) + ((retHeight / 2) - zoomReticuleCenterY);
		RenderHUDMaterial(c, zoomReticuleMaterial, zoomReticuleWidth, zoomReticuleHeight);
	}
	else
	{
		// render the reticule
		super.RenderElement(c);

		ReticuleSize = Min(retWidth, retHeight);
		HalfReticuleSize = ReticuleSize * 0.5;

		// render weapon spread
		if(SpreadAmount > 0)
		{
			CurrentSpreadSize = SpreadAmount * (MaxSpreadSize - ReticuleSize) * 0.5;

			// top left quadrant			
			c.CurX = ReticuleX - CurrentSpreadSize;
			c.CurY = ReticuleY - CurrentSpreadSize;
			RenderHUDMaterial(c, ReticuleTopLeft, HalfReticuleSize, HalfReticuleSize);

			// top right quadrant
			c.CurX = ReticuleX + (ReticuleSize * 0.5) + CurrentSpreadSize;
			c.CurY = ReticuleY - CurrentSpreadSize;
			RenderHUDMaterial(c, ReticuleTopRight, HalfReticuleSize, HalfReticuleSize);

			// bottom left quadrant
			c.CurX = ReticuleX - CurrentSpreadSize;
			c.CurY = ReticuleY + (ReticuleSize * 0.5) + CurrentSpreadSize;
			RenderHUDMaterial(c, ReticuleBottomLeft, HalfReticuleSize, HalfReticuleSize);

			// bottom right quadrant
			c.CurX = ReticuleX + (ReticuleSize * 0.5) + CurrentSpreadSize;
			c.CurY = ReticuleY + (ReticuleSize * 0.5) + CurrentSpreadSize;
			RenderHUDMaterial(c, ReticuleBottomRight, HalfReticuleSize, HalfReticuleSize);
		}
	}

	// render the reticule hit feedback if flash time is still valid
	if(hitTime + reticuleHitFeedbackFlashTime > timeSeconds)
	{
		c.CurX = ((Width - retHitWidth) / 2);
		c.CurY = ((Height - retHitHeight) / 2);
		RenderHUDMaterial(c, reticuleHitFeedbackMaterial, retHitWidth, retHitHeight);
	}

	// render out of ammo indicator
	if(bOutOfAmmo)
	{
		c.CurX = ReticuleX;
		c.CurY = ReticuleY;
		RenderHUDMaterial(c, NoAmmoIndicatorMaterial, ReticuleSize, ReticuleSize);
	}
}

defaultproperties
{
	NoWeaponReticuleMaterial=texture'HUD.ReticuleNone'

	reticuleHitFeedbackMaterial=(material=texture'HUD.Hit',drawColor=(R=255,G=255,B=255,A=255),style=1,fadeDuration=0.2,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=255),fadeTargetColor=(R=255,G=255,B=255,A=1))
	reticuleHitFeedbackFlashTime=0.2

	NoAmmoIndicatorMaterial=(material=texture'HUD.ReticuleCross',drawColor=(R=255,G=255,B=255,A=75),style=1,fadeDuration=0.2,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=255),fadeTargetColor=(R=255,G=255,B=255,A=75))

	zoomBlurMaterial=(material=texture'HUD.ZoomBorder',drawColor=(R=255,G=255,B=255,A=255),style=1)
	zoomReticuleMaterial=(material=texture'HUD.Zoom',drawColor=(R=255,G=255,B=255,A=255),style=1)
	zoomReticuleWidth=256
	zoomReticuleHeight=256
	zoomReticuleCenterX=128
	zoomReticuleCenterY=128

	ReticuleTopLeft=(drawColor=(R=255,G=255,B=255,A=255),style=1,bProgressControlled=true,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=45),fadeTargetColor=(R=255,G=255,B=255,A=255))
	ReticuleTopRight=(drawColor=(R=255,G=255,B=255,A=255),style=1,bProgressControlled=true,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=45),fadeTargetColor=(R=255,G=255,B=255,A=255))
	ReticuleBottomLeft=(drawColor=(R=255,G=255,B=255,A=255),style=1,bProgressControlled=true,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=45),fadeTargetColor=(R=255,G=255,B=255,A=255))
	ReticuleBottomRight=(drawColor=(R=255,G=255,B=255,A=255),style=1,bProgressControlled=true,bFading=true,fadeSourceColor=(R=255,G=255,B=255,A=45),fadeTargetColor=(R=255,G=255,B=255,A=255))
	MaxSpreadSize=384
}