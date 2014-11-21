class HUDElement extends Core.Object
	native
	abstract
	PerObjectConfig
	config(TribesHUD);

import enum EInputKey from Engine.Interaction;
import enum EInputAction from Engine.Interaction;
import enum ETeamAlignment from Gameplay.ClientSideCharacter;

enum ELayoutDirection
{
	LD_ManualLayout,
	LD_Horizontal,
	LD_Vertical
};

enum EHorizontalAlignment
{
	HALIGN_None,
	HALIGN_Relative,
	HALIGN_Left,
	HALIGN_Center,
	HALIGN_Right,
	HALIGN_Previous,
	HALIGN_Next
};

enum EHorizontalFill
{
	HFILL_None,
	HFILL_Relative,
	HFILL_Left,
	HFILL_Right,
	HFILL_Both
};

enum EVerticalAlignment
{
	VALIGN_None,
	VALIGN_Relative,
	VALIGN_Top,
	VALIGN_Middle,
	VALIGN_Bottom,
	VALIGN_Previous,
	VALIGN_Next
};

enum EVerticalFill
{
	VFILL_None,
	VFILL_Relative,
	VFILL_Up,
	VFILL_Down,
	VFILL_Both
};

struct native HUDMaterial
{
	// draw properties
	var() Material	material		"Material to eb rendered";
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
};

var() config HUDMaterial	backgroundTexture	"The background texture for the element";
var() config HUDMaterial	foregroundTexture	"The background texture for the element";

// Values for any text the component might render
var() config bool			bUseResFonts	"Whether to use the resolution fonts";
var() config Array<String>	resFontNames	"Array of font names, representing the fonts for different resolutions";
var() config Array<Font>	resFonts		"Array of fonts which will be used in differnet resolutions";
var() config String			textFontName	"Name fo the Font to use for the text";
var() config Font			textFont		"Font to use for the text";
var() config Color			textColor		"Color to use for the text";

// relative co-ordinates, loaded from config
var() config bool	bRelativePositioning;
var() config float	RelativePosX;
var() config float	RelativePosY;
var() config float	RelativeWidth;
var() config float	RelativeHeight;
var() config float	aspectRatio;		// if greater than 0, will be used to maintain a width/height relationship

// actual co-ordinates, calculated during the DoLayout call
// if the component uses relative positioning
var() config float posX;
var() config float posY;
var() config float Width;
var() config float Height;

var() config int offsetX;
var() config int offsetY;

var() config int insetX;
var() config int insetY;

var() config int borderTop;
var() config int borderLeft;
var() config int borderBottom;
var() config int borderRight;

// alignment properties
var() config EHorizontalAlignment horizontalAlignment;
var() config EHorizontalFill horizontalFill;
var() config EVerticalAlignment verticalAlignment;
var() config EVerticalFill verticalFill;

var() config private float	alpha;
var() config Color	defaultDrawColor;
var() config bool	bVisible;

var() String iniOverride;

// variables to store the initial configuration of the positional values
var float initialPosX;
var float initialPosY;
var float initialWidth;
var float initialHeight;

// full screen width & height
var float screenWidth;
var float screenHeight;

// dirty flagging
var bool bNeedsLayout;

// Parent container
var HUDContainer ParentElement;
var TribesHUDScript BaseScript;
var ClientSideCharacter LocalData;
var bool bRenderedOnce;

// Misc state information
var float timeSeconds;
var bool bIsLayingOut;

var HUDElement previousSibling;
var HUDElement nextSibling;

// Help screen related stuff
var String	HelpLabel;		// Label overlayed on the component to show what this component is
var String	HelpFontName;	// name of the font to render with
var Font	HelpFont;		// font to render the help label in

// flashing of whole element
var bool	bFlashing;			// whether we are flashing
var float	FlashPeriod;		// period of flash
var float	FlashDuration;		// Duration of the flash
var float	FlashStartTime;		// Time the flashing started
var float	FlashAlphaMin;		// Minimum alpha value for flash
var float	FlashAlphaMax;		// Maximum alpha value for flash
var float	TargetAlpha;		// Current alpha target value
var float	FlashSwitchTime;	// Time the flash switched from in to out

// --------------------------------------------------
// Native stuff

cpptext
{

	// Internal render HUD material, overloaded to optimise when tiling 
	// is not required (as in most cases)
	void RenderHUDMaterial(UCanvas *canvas, FHUDMaterial &mat, FLOAT matWidth, FLOAT matHeight);

	// Internal render HUD material. This version will tile the material
	// to the width of tileSizeX & tileSizeY
	void RenderHUDMaterial(UCanvas *c, FHUDMaterial &mat, FLOAT matWidth, FLOAT matHeight, FLOAT tileSizeX, FLOAT tileSizeY);

	// Interpolates a color between a source & target, based on a percentage progress
	// between the source and target.
	void InterpolateColor(FColor &newColor, FColor source, FColor target, float progress);

	// native set color call
	virtual void SetColor(UCanvas *canvas, FColor color);

	// Internal Render function
	virtual void Render(UCanvas *canvas);

	// Internal RenderElement function.
	virtual void RenderElement(UCanvas *canvas);

	// Native Update function
	virtual void Update();

	// Native Layout function
	virtual void Layout(UCanvas *canvas);

	// Internal horizontal packing function
	virtual void ResizeForWidth(UCanvas *canvas, INT pixelWidth);
}

//
// native RenderHUDMaterial declaration
//
// This is a special function to render a HUDMaterial object to the display.
// HUDMaterials have properties to handle flashing, fading, colors and styles 
// in a unified way. It is also a struct, to allow for easy initialisation 
// within a config file.
//
native function RenderHUDMaterial(Canvas c, out HUDMaterial mat, float matWidth, float matHeight, 
								  optional float tileSizeX, optional float tileSizeY);

// Native layout call
native function Layout(Canvas canvas);

// Native base Render function
native function Render(Canvas c);

// Native RenderElement function
native function NativeRenderElement(Canvas c);

// Native ResizeForWidth function
native function ResizeForWidth(Canvas c, int pixelWidth);

// Native function to load config from a spcific file
native function LoadConfig(String objectConfigName, class objectClass, optional String Filename);

static native function String EncodeColor(Color InColor);

//
// ---------------------------------------------------

//
// Key event methods. No defenition in the base class, elements must first
// register to receive keyEvents with the base HUDScript element before these 
// functions will be called.
//
function bool KeyType( EInputKey Key, string Unicode, HUDAction Response );
function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response );

function OnMouseEntered(HUDElement Sender);
function OnMouseExited(HUDElement Sender);
function OnMouseClicked(HUDElement Sender);
function OnMouseDoubleClicked(HUDElement Sender);

//
// Construction
//
overloaded function Construct()
{
	super.Construct();
}

function InitElement()
{
	initialPosX = PosX;
	initialPosY = PosY;
	initialWidth = Width;
	initialHeight = Height;

	LoadFonts();
}

//
// Initialises the element heirachy
//
function InitElementHeirachy(TribesHUDScript base, HUDContainer Parent)
{
	BaseScript = base;
	ParentElement = Parent;
	LocalData = BaseScript.LocalData;
}

// DoLayout function
event DoLayout(Canvas c)
{
	// native layout call
	Layout(c);
}

event SetNeedsLayout()
{
	bNeedsLayout = true;
	if(ParentElement != None)
		ParentElement.SetNeedsLayout();
}

event ForceNeedsLayout()
{
	bNeedsLayout = true;
}

function LoadFonts()
{
	local int i;

	ResFonts.Length = 6;
	for(i = 0; i < ResFontNames.Length; ++i)
		LoadFont(ResFontNames[i], ResFonts[i]);

	LoadFont(textFontName, textFont);
	LoadFont(helpFontName, helpFont);
}

function LoadFont(String FontName, out Font font)
{
	local Font NewFont;
	local String LocalFontName;	

	// get the *real* name of the font from the localisation file
	LocalFontName = Localize("Fonts", FontName, "Localisation\\GUI\\Fonts");

	// load the new font
	NewFont = Font(DynamicLoadObject(LocalFontName, class'Font'));
	if(NewFont == None)
		Log("Warning: "$Self$" Couldn't dynamically load font "$LocalFontName);
	else
		font = NewFont;

	// font is still none - give it a fallback
	if(font == None)
		font = Font(DynamicLoadObject("Engine_res.Res_DefaultFont", class'Font'));
}

event ResetFont()
{
	if(! bUseResFonts)
		return;

	if(screenWidth <= 640)
		textFont = resFonts[0];
	else if(screenWidth <= 800)
		textFont = resFonts[1];
	else if(screenWidth <= 1024)
		textFont = resFonts[2];
	else if(screenWidth <= 1280)
		textFont = resFonts[3];
	else if(screenWidth <= 1600)
		textFont = resFonts[4];
	else if(screenWidth > 1600)
		textFont = resFonts[5];
}

//
// Updates the element properties
//
event UpdateData(ClientSideCharacter c);

//
// Handles the actual rendering of element display. This defaults to calling
// a native render function. Script modders should override this function to
// get special rendering functionality, and can still call super the get the 
// native rendering as well.
//
event RenderElement(Canvas C)
{
	NativeRenderElement(C);
}

// convenience method for accessing the static one
function HUDElement CreateHUDElement(class<HUDElement> elementClass, String elementName, optional Object ownerObject)
{
	return Class.static.StaticCreateHUDElement(elementClass, elementName, ownerObject);
}

static function HUDElement StaticCreateHUDElement(class<HUDElement> elementClass, String elementName, optional Object ownerObject)
{
	local HUDElement element;

	element = HUDElement(FindObject(elementName, elementClass));

	if(element == None)
		element = new (None, elementName) elementClass;

	return element;
}

function HUDElement CreateClonedElement(string className, string objectName, optional string newObjectName)
{
	local HUDElement newElement;
	local class<HUDElement> newElementClass;

	newElementClass = class<HUDElement>(DynamicLoadObject(className, class'class'));

	// Create the template component
	newElement = CreateHUDElement(newElementClass, newObjectName);
	newElement.LoadConfig(objectName, newElementClass);

	return newElement;
}

function ResetHUDMaterial(out HUDMaterial mat)
{
	mat.fadeStartTime = timeSeconds;
	mat.lastFlashTime = timeSeconds;
	mat.bNoRender = false;
	mat.fadeProgress = 0.0;
}

function HUDMaterial MakeHUDMaterial(Material mat)
{
	local HUDMaterial hudMat;

	hudMat.material = mat;
	hudmat.drawColor.R = 255;
	hudmat.drawColor.G = 255;
	hudmat.drawColor.B = 255;
	hudmat.drawColor.A = 255;

	hudMat.style = 1;

	return hudMat;
}

event SetAlpha(float newAlpha)
{
	alpha = newAlpha;
}

function float GetAlpha()
{
	return alpha;
}

// must call this function when setting component color
function SetColor(Canvas C, Color newColor)
{
	C.SetDrawColor(newColor.R, newColor.G, newColor.B, Clamp(alpha * newColor.A, 1, 255));
}

function int GetX()
{
	return posX;
}

function int GetY()
{
	return posY;
}

function int GetWidth()
{
	return width;
}

function int GetHeight()
{
	return height;
}

function int InternalTop()
{
	return PosY + BorderTop;
}

function int InternalLeft()
{
	return PosX + BorderLeft;
}

function int InternalWidth()
{
	return Width - BorderLeft - BorderRight;
}

function int InternalHeight()
{
	return Width - BorderTop - BorderBottom;
}

function SetX(int newX)
{
	posX = newX;

	if(parentElement != None)
		RelativePosX = posX / ParentElement.Width;
	else
		RelativePosX = posX / screenWidth;
}

function SetY(int newY)
{
	posY = newY;

	if(parentElement != None)
		RelativePosY = posY / ParentElement.Width;
	else
		RelativePosY = posY / screenWidth;
}

function SetWidth(int newWidth)
{
	width = newWidth;

	if(parentElement != None)
		RelativeWidth = width / ParentElement.Width;
	else
		RelativeWidth = width / screenWidth;
}

function SetHeight(int newHeight)
{
	height = newHeight;

	if(parentElement != None)
		RelativeHeight = height / ParentElement.Height;
	else
		RelativeHeight = height / screenHeight;
}

function float GetMaximumRelativeX()
{
	return RelativePosX + RelativeWidth;
}

function float GetMaximumRelativeY()
{
	return RelativePosY + RelativeHeight;
}

function float GetMaximumX()
{
	return PosX + Width;
}

function float GetMaximumY()
{
	return PosY + Height;
}

function int MaterialWidth(HUDMaterial mat)
{
	if(mat.Coords.UL <= 0 && mat.Material != None)
		return mat.Material.GetUSize();
	else
		return mat.Coords.UL;
}

function int MaterialHeight(HUDMaterial mat)
{
	if(mat.Coords.VL <= 0 && mat.Material != None)
		return mat.Material.GetVSize();
	else
		return mat.Coords.VL;
}

function TribesHUDScript RootHUDScript()
{
	return BaseScript;
}

function GetScreenPos(out int ScreenPosX, out int ScreenPosY)
{
	ScreenPosX += PosX;
	ScreenPosY += PosY;

	if(ParentElement != None)
		ParentElement.GetScreenPos(ScreenPosX, ScreenPosY);
}

function bool PointInElement(int PointX, int PointY)
{
	local int ScreenPosX, ScreenPosY;
	GetScreenPos(ScreenPosX, ScreenPosY);
	
	// calculate whether the point is in the element
	return PointInRegion(PointX, PointY, ScreenPosX, ScreenPosY, ScreenPosX + Width, ScreenPosY + Height);
}

function bool PointInRegion(int PointX, int PointY, int X1, int Y1, int X2, int Y2)
{
	// calculate whether the point is in the element
	if(PointX > X1 && PointX < X2 && PointY > Y1 && PointY < Y2)
		return true;

	return false;
}

function FlashElement(float period, float duration, float AlphaMin, float AlphaMax)
{
	bFlashing = true;
	FlashPeriod = period;
	FlashDuration = duration;
	FlashStartTime = TimeSeconds;
	FlashSwitchTime = TimeSeconds;
	FlashAlphaMin = AlphaMin;
	FlashAlphaMax = AlphaMax;
	TargetAlpha = FlashAlphaMax;
}

function String EncodePlayerName(String PlayerName, String TeamTag, ETeamAlignment alignment, optional class<TeamInfo> PlayerTeam)
{
	local int Index;
	local String NameReplacementTag;
	local String ReturnString;
	local Color NameColor, TagColor;

	NameColor = LocalData.GetTeamColor(alignment, false, PlayerTeam);
	TagColor = LocalData.GetTeamColor(alignment, true, PlayerTeam);

	NameReplacementTag = "<NAME>";
	Index = InStr(TeamTag, NameReplacementTag);
	if(Index == -1)
	{
		Index = 0;
		NameReplacementTag = "";
	}
	if(TeamTag != "")
		ReturnString = "[C=" $ EncodeColor(TagColor) $ "]" $ 
						Left(TeamTag, Index) $ 
						"[C=" $ EncodeColor(NameColor) $ "]" $ 
						PlayerName $ 
						"[\\C]" $ 
						Mid(TeamTag, Index + Len(NameReplacementTag)) $ 
						"[\\C]";
	else
		ReturnString = 	"[C=" $ EncodeColor(NameColor) $ "]" $ 
						PlayerName $ 
						"[\\C]";


	return ReturnString;
}

defaultproperties
{
	alpha = 1
	bVisible = true
	bNeedsLayout = true

	RelativePosX = 0
	RelativePosY = 0
	RelativeWidth = 1
	RelativeHeight = 1

	verticalFill = VFILL_None
	horizontalFill = HFILL_None
	verticalAlignment = VALIGN_None
	horizontalAlignment = HALIGN_None

	defaultDrawColor=(R=255,G=255,B=255,A=255)

	bUseResFonts	= false
	resFontNames(0)	= DefaultSmallFont
	resFontNames(1)	= Tahoma8
	resFontNames(2)	= Tahoma8
	resFontNames(3)	= Tahoma10
	resFontNames(4)	= Tahoma12
	resFontNames(5)	= Tahoma12
	resFonts(0)		= font'Engine_res.res_defaultFont'
	resFonts(1)		= font'TribesFonts.Tahoma8'
	resFonts(2)		= font'TribesFonts.Tahoma8'
	resFonts(3)		= font'TribesFonts.Tahoma10'
	resFonts(4)		= font'TribesFonts.Tahoma12'
	resFonts(5)		= font'TribesFonts.Tahoma12'

	textFontName	= res_defaultFont
	textFont		= font'Engine_res.res_defaultFont'
	textColor		= (R=255,G=255,B=255,A=255)

	HelpFontName	= Tahoma8
	HelpFont		= font'TribesFonts.Tahoma8'
}
