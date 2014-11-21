class TsActionCameraOverlay extends TsCameraAction;

var() Material	Material;
var() Color		ColorStart;
var() Color		ColorEnd;
var() float		U0;
var() float		V0;
var() float		U1;
var() float		V1;
var() float		X0;
var() float		Y0;
var() float		X1;
var() float		Y1;
var() float		Duration;
var() float		ColorFadeInDuration;
var() float		ColorFadeOutDuration;
var() float		ColorEaseIn;
var() float		ColorEaseOut;
var() bool		bCinematics;

var transient MessageRouter Router;
var transient float			time;
var transient bool			bFadeOut;
var transient Color			ColorCurrent;


function bool OnStart()
{
	local float alpha;

	if (Router == None)
	{
		Router = Actor.spawn(class'MessageRouter');
		Router.Set(self, class'MessagePostRender', "all");
	}

	resetInterpolation(ColorEaseIn, ColorFadeInDuration, ColorEaseOut);

	time = 0;
	bFadeOut = false;

	if (bFadeOut)
		alpha = 0;
	else
		alpha = 1;

	ColorCurrent.R = ColorStart.R + (ColorEnd.R - ColorStart.R) * alpha;
	ColorCurrent.G = ColorStart.G + (ColorEnd.G - ColorStart.G) * alpha;
	ColorCurrent.B = ColorStart.B + (ColorEnd.B - ColorStart.B) * alpha;
	ColorCurrent.A = ColorStart.A + (ColorEnd.A - ColorStart.A) * alpha;

	return true;	
}

event OnDelete()
{
	if (Router != None)
		Router.Destroy();
}

function bool OnTick(float delta)
{
	local float alpha;
	local bool bFinished;

	time += delta;

	if (!bFadeOut && time > Duration - ColorFadeOutDuration)
	{
		bFadeOut = true;
		resetInterpolation(ColorEaseIn, ColorFadeOutDuration, ColorEaseOut);
	}

	bFinished = tickInterpolation(delta, alpha);

	if (bFadeOut)
	{
		alpha = 1 - alpha;
	}

	ColorCurrent.R = ColorStart.R + (ColorEnd.R - ColorStart.R) * alpha;
	ColorCurrent.G = ColorStart.G + (ColorEnd.G - ColorStart.G) * alpha;
	ColorCurrent.B = ColorStart.B + (ColorEnd.B - ColorStart.B) * alpha;
	ColorCurrent.A = ColorStart.A + (ColorEnd.A - ColorStart.A) * alpha;

	return time < Duration;
}

function OnFinish()
{
	Router.Destroy();
	Router = None;
}

function Interrupt()
{
	OnFinish();
}

function Message(Message msg)
{
	local MessagePostRender m;
	local float ClipX, ClipY;
	local float NewY0, NewY1;

	m = MessagePostRender(msg);
	ClipX = m.Canvas.ClipX;
	ClipY = m.Canvas.ClipY;
	m.canvas.Style = Actor.ERenderStyle.STY_Alpha;

	if (bCinematics)
	{
		// in cinematic mode, y screen extent is 60% of x
		NewY0 = 0.2f + (Y0 * 0.6f) - (1.0 / ClipY);
		NewY1 = NewY0 + ((Y1 - Y0) * 0.6f) + (1.0 / ClipY);
	}
	else
	{
		NewY0 = Y0;
		NewY1 = Y1;
	}

	// Post Render
	m.Canvas.CurX = X0 * ClipX;
	m.Canvas.CurY = NewY0 * ClipY;
	m.Canvas.DrawColor = ColorCurrent;

	m.Canvas.DrawTile(
						Material,
						(X1 - X0) * ClipX,
						(NewY1 - NewY0) * ClipY,
						U0,
						V0,
						U1 - U0,
						V1 - V0
					);
}

function bool SetDuration(float _duration)
{
	Duration = _duration;
	return true;
}

function float GetDuration()
{
	return Duration;
}


defaultproperties
{
	DName					="Overlay"
	Track					="Effects"
	Help					="Renders a material overlay on the camera. The effect persists for the specified duration. X and Y coords range from 0 to 1, U and V coords range from 0 to the texture's width and height."

	UsesDuration			=true

	Material				=texture'engine_res.DefaultTexture'
	ColorStart				=(R=255,G=255,B=255,A=1)
	ColorEnd				=(R=255,G=255,B=255,A=128)
	U0						=0
	V0						=0
	U1						=128
	V1						=128
	X0						=0
	Y0						=0
	X1						=1
	Y1						=1
	Duration				=5
	ColorFadeInDuration		=1
	ColorFadeOutDuration	=1
	ColorEaseIn				=0
	ColorEaseOut			=0
	bCinematics				=true
}