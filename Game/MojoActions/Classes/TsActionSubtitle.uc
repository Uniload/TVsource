class TsActionSubtitle extends TsCameraAction;

var() string Filename			"Name of the localization file (do not include the .int)";
var() string SectionName		"SectionName under which the text resides";
var() string TextName			"The name of the text to display";
var() string Path				"The path of the localization file. You don't usually need to change this.";
var() string FontName			"Name of font to use";
var() Color ForegroundColor;
var() Color BackgroundColor;
var() int Wrap					"Set to 1 to have the text wrap around";
var() int Center				"Set to 1 to center the text within the draw area";

var() float FadeInTime;
var() float FadeHoldTime;
var() float FadeOutTime;

var() float DrawX				"Choose a value from 0 to 1";
var() float DrawY				"Choose a value from 0 to 1";
var() float DrawSizeX			"Choose a value from 0 to 1";
var() float DrawSizeY			"Choose a value from 0 to 1";

var float totalTime;
var transient MessageRouter Router;
var float alpha;
var string textString;
var Font Font;

function bool OnStart()
{
	local string LocalFontName;
	local Font NewFont;

	textString = Localize(SectionName, TextName, Path $ "/" $ Filename);

	if (Font == None)
	{
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

	totalTime = 0;
	alpha = 0;
	if (Router == None)
	{
		Router = Actor.spawn(class'MessageRouter');
		Router.Set(self, class'MessagePostRenderFinal', "all");
	}

	return true;
}

function bool OnTick(float delta)
{
	totalTime += delta;

	if (totalTime > fadeInTime + fadeHoldTime + fadeOutTime)
	{
		return false;
	}

	if (totalTime < fadeInTime)
	{
		alpha = totalTime / fadeInTime;
	}
	else if (totalTime < fadeInTime + fadeHoldTime)
	{
		alpha = 1.0;
	}
	else
	{
		alpha = 1.0 - ((totalTime - (fadeInTime + fadeHoldTime)) / fadeOutTime);
	}

	return true;
}

function OnFinish()
{
	if (Router != None)
	{
		Router.Destroy();
		Router = None;
	}
}

function Interrupt()
{
	OnFinish();
}

event OnDelete()
{
	OnFinish();
}

function Message(Message msg)
{
	local MessagePostRenderFinal m;
	local Vector v;
	local Color fore;
	local Color back;
	local float ClipX;
	local float ClipY;

	m = MessagePostRenderFinal(msg);

	ClipX = m.Canvas.ClipX;
	ClipY = m.Canvas.ClipY;

	m.Canvas.CurX = 0;
	m.Canvas.CurY = 0;
	m.Canvas.ClipX = drawSizeX * m.Canvas.SizeX;
	m.Canvas.ClipY = drawSizeY * m.Canvas.SizeY;
	m.Canvas.Style = Actor.ERenderStyle.STY_Alpha;
	m.Canvas.DrawColor.R = 255;
	m.Canvas.DrawColor.G = 255;
	m.Canvas.DrawColor.B = 255;
	m.Canvas.DrawColor.A = 255;
	m.Canvas.Font = Font;

	fore = ForegroundColor;
	fore.A = float(fore.A) * alpha;
	back = BackgroundColor;
	back.A = float(back.A) * alpha;

	v.x = drawX * m.Canvas.SizeX;
	v.y = drawY * m.Canvas.SizeY;

	m.Canvas.DrawTextMultiline(
						textString,
						v,
						fore,
						back,
						Wrap,
						Center
					);

	m.Canvas.ClipX = ClipX;
	m.Canvas.ClipY = ClipY;
}

defaultproperties
{
	DName			="Subtitle"
	Track			="Effects"
	Help			="Draws a text subtitle on the screen."

	SectionName		="Cutscenes"
	Path			="Localisation/Cutscenes/text files"

	Font			=Font'Engine_res.Res_DefaultFont'

	fadeInTime		=1
	fadeHoldTime	=3
	fadeOutTime		=1

	ForegroundColor	=(R=255,G=255,B=255,A=255)
	BackgroundColor	=(R=0,G=0,B=0,A=0)

	drawX			=0.1
	drawY			=0.85
	drawSizeX		=0.8
	drawSizeY		=0.2

	Wrap			=1
	Center			=1
}