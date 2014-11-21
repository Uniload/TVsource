/*******************************************************************************
 * OHUDMaterial 0.1 by Cactusbone
 * 20 november 2004
 *
 * This is an Object version of the HUDMaterial structure ... this was done to
 * be able to pass HUDMaterial by reference instead of by value.
 ******************************************************************************/
class OHUDMaterial extends TribesGUI.HUDElement;
//have to extends HUDElement to use the HUDMaterial struct :/


// draw properties
var() Material	material		"Material to be rendered";
var() Color		drawColor		"Draw color";
var() MatCoords	coords			"Texture coordinates (in pixels) of the location of the desired section in the material";
var() byte		style			"Render style - set to 1";
var() bool		bStretched		"Whether the render the material stretched (good for button borders etc)";
// draw state info
var bool		bNoRender;

// whether the progress of flashing & fading is controlled externally
var bool		bProgressControlled;

// flash properties
var() bool		bFlashing		"Flashing flag";
var() float		flashFrequency	"Frequency of the flash on/off time (in seconds)";
// flash state info
var float		lastFlashTime;

// fade properties
var() bool		bFading			"Fading flag";
var() bool		bFadePulse		"Whether to pulse the fade in and out";
var() Color		fadeSourceColor	"Color to fade from";
var() Color		fadeTargetColor	"Color to fade to";
var() float		fadeDuration	"How long the fade should take in seconds";
// fade state info
var float		fadeStartTime;
var float		fadeProgress;


//******************************************
//Stuff not in HUDMaterial struct

var int nbFlashed;

overloaded function Construct(out HUDMaterial mat)
{
    self.material = mat.material;
    self.drawColor = mat.drawColor;
    self.coords = mat.coords;
    self.style = mat .style;
    self.bStretched = mat.bStretched;
    self.bNoRender = mat.bNoRender;
    self.bProgressControlled = mat.bProgressControlled;
    self.bFlashing = mat.bFlashing;
    self.flashFrequency = mat.flashFrequency;
    self.lastFlashTime = mat.lastFlashTime;
    self.bFading = mat.bFading;
    self.bFadePulse = mat.bFadePulse;
    self.fadeSourceColor = mat.fadeSourceColor;
    self.fadeTargetColor = mat.fadeTargetColor;
    self.fadeDuration = mat.fadeDuration;
    self.fadeStartTime = mat.fadeStartTime;
    self.fadeProgress = mat.fadeProgress;

    completeHUDMaterial();
}

function color getFlashingColor()
{
    local color C;

	C.R = self.DrawColor.R;
	C.G = self.DrawColor.G;
	C.B = self.DrawColor.B;

	if(self.DrawColor.A>=128)
        C.A = self.DrawColor.A-64;
	else
	    C.A = self.DrawColor.A+64;
	return C;
}

function completeHUDMaterial()
{
    if(self.coords.UL<=0)
         self.coords.UL=self.Material.GetUSize();
    if(self.coords.VL<=0)
         self.coords.VL=self.material.GetVSize();
}

function InitElement();

function UpdateData(ClientSideCharacter c);

function RenderElement(Canvas c);

//Removes the corrupt file error
event NotifyLevelChange()
{
    class'staticFunctions'.static.removeElement(self.ParentElement, self);
}

defaultproperties
{
     nbFlashed=3
     resFontNames(0)="DefaultSmallFont"
     resFontNames(1)="Tahoma8"
     resFontNames(2)="Tahoma8"
     resFontNames(3)="Tahoma10"
     resFontNames(4)="Tahoma12"
     resFontNames(5)="Tahoma12"
     resFonts(0)=Font'Engine_res.Res_DefaultFont'
     resFonts(1)=Font'TribesFonts.Tahoma8'
     resFonts(2)=Font'TribesFonts.Tahoma8'
     resFonts(3)=Font'TribesFonts.Tahoma10'
     resFonts(4)=Font'TribesFonts.Tahoma12'
     resFonts(5)=Font'TribesFonts.Tahoma12'
}
